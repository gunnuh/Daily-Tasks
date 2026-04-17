public class logical {
    public static void fun(){
        try{
            Profile p = [select Id from Profile where Name = 'System Administrator LIMIT 1'];
            User u=new User(FirstName='New', LastName='Admin',Email='abc@gmail.com',Username='jsmksmj'+System.currentTimeMillis()+'@test.com', Alias='ndadm',
                           TimeZoneSidKey='Asia/Kolkata', LocaleSidKey='en_us',EmailEncodingKey = 'UTF-8', ProfileId=p.Id, LanguageLocaleKey='en_us');
            insert u;
            System.debug('user created');
        }
        catch(Exception e){
            System.debug('Error is '+e.getMessage());
        }
    }
}