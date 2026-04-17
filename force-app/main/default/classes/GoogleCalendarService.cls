public class GoogleCalendarService {
    @future(callout=true)
    public static void createCalendarEvents(List<Id> eventIds) {
        List<Event> events = [SELECT Id, Subject, StartDateTime, EndDateTime, Description, OwnerId, Owner.Email, WhoId FROM Event WHERE Id IN :eventIds];
        for (Event e : events) {
            createGoogleCalendarEvent(e);
            sendEmailToContact(e);
        }
    }

    private static void createGoogleCalendarEvent(Event e) {
        String startTime = formatDateTime(e.StartDateTime);
        String endTime;
        if (e.EndDateTime == null) {
            endTime = formatDateTime(e.StartDateTime.addHours(1));
        } else {
            endTime = formatDateTime(e.EndDateTime);
        }
        Map<String, Object> eventBody = new Map<String, Object>{
            'summary'     => e.Subject != null ? e.Subject : 'Salesforce Event',
            'description' => e.Description != null ? e.Description : '',
            'start' => new Map<String, String>{
                'dateTime' => startTime,
                'timeZone' => 'Asia/Kolkata'
            },
            'end' => new Map<String, String>{
                'dateTime' => endTime,
                'timeZone' => 'Asia/Kolkata'
            }
        };
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:GoogleCalendarDemo/calendar/v3/calendars/primary/events');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(eventBody));
            req.setTimeout(120000);
            HttpResponse res = new Http().send(req);
            System.debug('Status Code: ' + res.getStatusCode());
            System.debug('Response: ' + res.getBody());
        } catch (Exception ex) {
            System.debug('Exception: ' + ex.getMessage());
        }
    }

    private static void sendEmailToContact(Event e) {
        System.debug('function callled');
        try {
            if (e.WhoId == null) {
                System.debug('WhoId is null, skipping');
                return;
            }
            String contactEmail = null;
            String contactName  = null;
            if (e.WhoId.getSObjectType() == Contact.SObjectType) {
                Contact c    = [SELECT Name, Email FROM Contact WHERE Id = :e.WhoId LIMIT 1];
                contactEmail = c.Email;
                contactName  = c.Name;
            } else if (e.WhoId.getSObjectType() == Lead.SObjectType) {
                Lead l       = [SELECT Name, Email FROM Lead WHERE Id = :e.WhoId LIMIT 1];
                contactEmail = l.Email;
                contactName  = l.Name;
            }
            if (String.isBlank(contactEmail)) {
                System.debug('Email is blank, skipping');
                return;
            }
            String eventLink = 'https://orgfarm-5dd1fb1674-dev-ed.develop.lightning.force.com/lightning/r/Event/' + e.Id + '/view';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ contactEmail });
            mail.setSubject('Meeting Scheduled: ' + e.Subject);
            mail.setPlainTextBody(
                'Dear ' + contactName + ',\n\n' +
                'Subject     : ' + e.Subject + '\n' +
                'Start Time  : ' + e.StartDateTime.format('dd MMM yyyy hh:mm a') + '\n' +
                'Description : ' + e.Description + '\n\n' +
                'Event Link  : ' + eventLink + '\n\n' +
                'Regards,\nSalesforce Team'
            );
            mail.setSaveAsActivity(false);
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(
                new List<Messaging.SingleEmailMessage>{ mail }
            );
            for (Messaging.SendEmailResult r : results) {
                if (r.isSuccess()) {
                    System.debug('Email sent to: ' + contactEmail);
                } else {
                    for (Messaging.SendEmailError err : r.getErrors()) {
                        System.debug('Email Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('Email Exception: ' + ex.getTypeName() + ' - ' + ex.getMessage());
            System.debug('Stack Trace: ' + ex.getStackTraceString());
        }
    }

    private static String formatDateTime(DateTime dt) {
        if (dt == null) return null;
        return dt.format('yyyy-MM-dd\'T\'HH:mm:ss+05:30');
    }
}