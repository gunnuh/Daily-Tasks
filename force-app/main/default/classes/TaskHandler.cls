public class TaskHandler {
    public static void preventdelete(List<Task> tasklist){
        String pname = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        if(pname != 'System Administrator'){
            for(Task t: tasklist){
                t.addError('Only System Administrator can delete tasks.');
            }
        }
    }
}