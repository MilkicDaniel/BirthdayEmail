@isTest(SeeAllData=false)
public class TestBirthdayEmail {
        
    //adding a contact with a birthday today
    @TestSetup
    private static void addContacts(){
        Contact contact = new Contact(FirstName='john-test', LastName='smith-test', Email='test@gmail.com', Birthdate=Date.today());
        insert contact;     
    }
    
    @isTest static void testSendBirthdayEmails(){
        Test.setMock(HttpCalloutMock.class, new getResponseFromCelebritybucksMock());
      	Test.startTest();
        BirthdayEmail.sendBirthdayMessage();
        Integer invocations = Limits.getEmailInvocations();   
        System.assertEquals(1, invocations, 'failed to send birthday email from a valid json');
        Test.stopTest();
    }
    
    @isTest static void testSendBirthdayEmailsNoBirthdays(){
        Test.setMock(HttpCalloutMock.class, new getResponseFromCelebritybucksMock());
        Test.startTest();
        delete [Select FirstName, Email FROM Contact WHERE Birthdate = TODAY AND Email != null];
        BirthdayEmail.sendBirthdayMessage();
        Integer invocations = Limits.getEmailInvocations();   
        System.assertEquals(0, invocations, 'sent a birthday email when there was no birthday');
        Test.stopTest();
    }
    
    @isTest static void testSendBirthdayEmailsNoCelebrityBirthday(){
        Test.setMock(HttpCalloutMock.class, new getNoBirthdayResponseFromCelebritybucksMock());
        Test.startTest();
        BirthdayEmail.sendBirthdayMessage();
        Integer invocations = Limits.getEmailInvocations();   
        System.assertEquals(1, invocations, 'failed to send default email with no celebrity birthdays');
        Test.stopTest();
    }
    
    @isTest static void testSendBirthdayEmailsWith404(){
        Test.setMock(HttpCalloutMock.class, new get404ResponseFromCelebritybucksMock());
        Test.startTest();
        BirthdayEmail.sendBirthdayMessage();
        Integer invocations = Limits.getEmailInvocations();   
        System.assertEquals(1, invocations, 'failed to send default email with 404 from celebritybucks');
        Test.stopTest();
    }
    
    //getting valid response
    private class getResponseFromCelebritybucksMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'text/json');
            response.setBody('{"Birthdays":[{"celebId":"2015","name":"Demi Lovato","dob":"1992-08-20","havePic":"1","twitter":"ddlovato","price":66000,"age":28},{"celebId":"8755","name":"Andrew Garfield","dob":"1983-08-20","havePic":"1","twitter":"","price":10000,"age":37},{"celebId":"422","name":"Amy Adams","dob":"1974-08-20","havePic":"1","twitter":"","price":8000,"age":46},{"celebId":"1959","name":"David Walliams","dob":"1971-08-20","havePic":"0","twitter":"davidwalliams","price":7000,"age":49},{"celebId":"5138","name":"Linda Manz","dob":"1961-08-20","havePic":"0","twitter":"","price":7000,"age":59},{"celebId":"8937","name":"Fred Durst","dob":"1970-08-20","havePic":"1","twitter":"freddurst","price":3000,"age":50},{"celebId":"4064","name":"Joan Allen","dob":"1956-08-20","havePic":"1","twitter":"","price":3000,"age":64},{"celebId":"9385","name":"Al Roker","dob":"1954-08-20","havePic":"1","twitter":"","price":0,"age":66},{"celebId":"249","name":"Alan Reed","dob":"1907-08-20","havePic":"0","twitter":"","price":0,"age":113},{"celebId":"880","name":"Bernard Archard","dob":"1916-08-20","havePic":"0","twitter":"","price":0,"age":104},{"celebId":"1357","name":"Charles Arnt","dob":"1906-08-20","havePic":"0","twitter":"","price":0,"age":114},{"celebId":"3126","name":"Guido Alberti","dob":"1909-08-20","havePic":"0","twitter":"","price":0,"age":111},{"celebId":"3452","name":"Isaac Hayes","dob":"1942-08-20","havePic":"1","twitter":"","price":0,"age":78},{"celebId":"3638","name":"James Marsters","dob":"1962-08-20","havePic":"1","twitter":"","price":0,"age":58},{"celebId":"4296","name":"John Noble","dob":"1948-08-20","havePic":"0","twitter":"","price":0,"age":72},{"celebId":"5963","name":"Michael Rady","dob":"1981-08-20","havePic":"1","twitter":"","price":0,"age":39},{"celebId":"6685","name":"Peter Horton","dob":"1953-08-20","havePic":"0","twitter":"","price":0,"age":67},{"celebId":"6871","name":"Ray Wise","dob":"1947-08-20","havePic":"1","twitter":"","price":0,"age":73},{"celebId":"8021","name":"Theresa Saldana","dob":"1954-08-20","havePic":"0","twitter":"","price":0,"age":66},{"celebId":"8465","name":"Yoko Tsukasa","dob":"1934-08-20","havePic":"0","twitter":"","price":0,"age":86}]}');
            response.setStatusCode(200);
            return response;
        }
    }
    
    //getting response but with no birthdays
    private class getNoBirthdayResponseFromCelebritybucksMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'text/json');
            response.setBody('{"Birthdays":[]}');
            response.setStatusCode(200);
            return response;
        }
    }
     //site returns 404 error
     private class get404ResponseFromCelebritybucksMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request) {
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(404);
            return response;
        }
    }   
        
}