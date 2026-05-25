/*
 * Name: PreventCaseDeletionTrigger
 * Author Name: Ankit Kumar
 * Description: Prevent deletion of Case records where the Status is Escalated
 * Date: 01/09/25
 */
trigger PreventCaseDeletionTrigger on Case (before delete) {
    for (Case c : Trigger.old) {
        if (c.Status == 'Escalated') {
            c.addError('You cannot delete a Case when its Status is Escalated.');
        }
    }
}