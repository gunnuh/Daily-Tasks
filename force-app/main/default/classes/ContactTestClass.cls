@isTest
public class ContactTestClass {
    @isTest
    public static void testEmail(){
        EmailTemplate temp = new EmailTemplate(Name = 'Contact_Welcome_Template', DeveloperName = 'Contact_Welcome_Template', FolderId = UserInfo.getUserId(), TemplateType = 'text', Subject = 'Test Subject', Body = 'Hello {!Contact.Name}');
        insert temp;
        List<Contact> conlist = new List<Contact>{
            new Contact (LastName = 'Test1', Email = 'sanjana.pal@learnowx.com'),
            new Contact (LastName = 'Test2', Email = 'sanjana.pal@learnowx.com')
        };
        Test.startTest();
        insert conlist;
        Test.stopTest();
        System.assertEquals(2,[select COUNT() from Contact]);
        System.assert(Limits.getEmailInvocations() > 0);
    }
}