public with sharing class BirthdayEmail {
    
    public static void sendBirthdayMessage() {

        //Birthdate field is special and lets you use TODAY to get birthdays regardless of birth year
        Contact[] contacts = [Select Name, Email FROM Contact WHERE Birthdate = TODAY AND Email != null];
        
        //returning if no one has a birthday today
        if(contacts.size() == 0)
            return;

        //getting json with list of celebrities who were born today from celebritybucks
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://celebritybucks.com/developers/birthdays/JSON');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept','application/json');
        HttpResponse response = new Http().send(request);
        //json returned
        if(response.getstatusCode() == 200 && response.getBody() != null) {

            CelebrityBirthdayList celebrityBirthdayList = (CelebrityBirthdayList) JSON.deserialize(response.getBody(), 
            CelebrityBirthdayList.class);
            //no celebrity birthdays today sending default message
            if(celebrityBirthdayList.Birthdays.size() == 0){
                sendDefaultMessage(contacts);
                return;
            }
            
            String celebName = celebrityBirthdayList.Birthdays.get(0).name;
            Integer celebAge = System.Today().year() - Integer.valueof(celebrityBirthdayList.Birthdays.get(0).dob.split('-')[0]);

            for(Contact contact : contacts){
                sendMessage(contact.Email,
                    'Happy Birthday!',
                    'Hello ' + contact.Name.split(' ')[0] + ', did you know that today ' + celebName 
                    + ' turned ' + celebAge + ' years old? Isn\'t that amazing.\n\nP.S\n\n' 
                    +  'If you reach out through social media please don\'t mention that it\'s your birthday.\n'
                    +  'We wouldn\'t want to detract from ' + celebName.split(' ')[0] + '\'s special day.\n\n'
                    +  'All the best from Kramllah\n');
                }
        }
        // json not returned sending standard email
        else {
            sendDefaultMessage(contacts);
        }
    }

    private static void sendDefaultMessage(Contact[] contacts){
        for(Contact contact : contacts){
            sendMessage(contact.Email, 
                'Happy Birthday, ' + (contact.Name.split(' ')[0]) + '!', 
                'We here at Kramllah would like to wish you all the best on this wonderful day.');
        }
    }
    
    private static void sendMessage(String email, String subject, String textBody){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {email};
        message.setToAddresses(toAddresses);
        message.setSubject(subject);
        message.setPlainTextBody(textBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
}
