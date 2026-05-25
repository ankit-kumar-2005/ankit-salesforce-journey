public class MyClass {
   public static Account function(String tmc){
        Account acc=[SELECT id FROM Account WHERE NAME=:tmc LIMIT 1];
         return acc;
      }
}