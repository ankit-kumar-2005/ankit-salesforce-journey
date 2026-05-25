/*
 @Name: MyCollectionExample
 @Author: Ankit Kumar
 @Description: Examples of Collections in Apex - Lists, Sets, Maps and their operations
 @Date: 28/08/2025
 @ReturnType: void for all methods
*/
public class MyCollectionExample {

    // -------------------------
    // Question 01: Sort and modify city list
    // @ReturnType: void
    // -------------------------
    public static void sortAndModifyCityList(){
        List<String> city = new List<String>{'Delhi','Jaipur','Agra','Patna','Nagpur'};
        city.sort();      
        System.debug('City name after Sorting = ' + city);
        city.remove(1);
        System.debug('Final list of City name = ' + city);
    }

    // -------------------------
    // Question 02: Set operations
    // @ReturnType: void
    // -------------------------
    public static void setOperations(){
        Set<Integer> numberSet = new Set<Integer>{10, 20, 20, 30, 40, 10};
        for(Integer it : numberSet){
            System.debug(it);
        }
        if(numberSet.contains(25)){
            System.debug('25 exists in the set');
        } else {
            System.debug('25 does not exist in the set');
        }
    }

    // -------------------------
    // Question 04: Remove duplicates from a list
    // @ReturnType: void
    // -------------------------
    public static void removeDuplicatesExample() {
        List<String> nameList = new List<String>{'Aman', 'Riya', 'Aman', 'Sita', 'Riya'};
        System.debug('Original List: ' + nameList);
        Set<String> nameSet = new Set<String>(nameList);
        System.debug('Set (unique values): ' + nameSet);
        List<String> uniqueNameList = new List<String>(nameSet);
        System.debug('Final List (duplicates removed): ' + uniqueNameList);
    }

    // -------------------------
    // Question 05: Sort list ascending and descending
    // @ReturnType: void
    // -------------------------
    public static void sortListAscendingDescending(){
        List<Integer> myList = new List<Integer>{50, 20, 70, 10};
        System.debug('Original List: ' + myList);
        myList.sort();
        System.debug('List after sorting in ascending order: ' + myList);
        List<Integer> descList = new List<Integer>();
        for(Integer i = myList.size()-1; i >= 0; i--){
            descList.add(myList[i]);
        }
        System.debug('List after sorting in descending order: ' + descList);
    }

    // -------------------------
    // Question 06: Get capital by country using Map
    // @ReturnType: void
    // -------------------------
    public static void getCapitalByCountry(){
        Map<String,String> myMap = new Map<String,String>();
        myMap.put('India','New Delhi');
        myMap.put('Japan','Tokyo');
        myMap.put('UK','London');
        String countryName = 'India';
        if(myMap.containsKey(countryName)){
            System.debug('Capital of ' + countryName + ' is ' + myMap.get(countryName));
        } else {
            System.debug('Not Available');
        }
    }

    // -------------------------
    // Question 07: Nested map of countries, cities, and monuments
    // @ReturnType: void
    // -------------------------
    public static void printCountriesCitiesMonuments() {
        Map<String, Map<String, List<String>>> countryMap = new Map<String, Map<String, List<String>>>();
        Map<String, List<String>> indiaCities = new Map<String, List<String>>();
        indiaCities.put('Delhi', new List<String>{'Red Fort', 'Qutub Minar'});
        indiaCities.put('Agra', new List<String>{'Taj Mahal'});
        countryMap.put('India', indiaCities);
        Map<String, List<String>> usCities = new Map<String, List<String>>();
        usCities.put('NYC', new List<String>{'Statue of Liberty'});
        countryMap.put('US', usCities);

        for(String country : countryMap.keySet()) {
            System.debug('Country: ' + country);
            for(String city : countryMap.get(country).keySet()) {
                System.debug('  City: ' + city);
                for(String monument : countryMap.get(country).get(city)) {
                    System.debug('    Monument: ' + monument);
                }
            }
        }
    }

    // -------------------------
    // Question 08: Sort students by name from a map
    // @ReturnType: void
    // -------------------------
    public static void sortStudentsByName(){
        Map<String,Integer> studentNameMarksMap = new Map<String,Integer>{
            'Ankit' => 70,
            'Amit'  => 90,
            'Pankaj'=> 60,
            'Shreya'=> 80,
            'Anjali'=> 95
        };
        System.debug('Original Map: ' + studentNameMarksMap);
        List<String> studentNames = new List<String>(studentNameMarksMap.keySet());
        studentNames.sort();
        for (String name : studentNames) {
            System.debug('Student: ' + name + ', Marks: ' + studentNameMarksMap.get(name));
        }
    }

    // -------------------------
    // Question 09: Remove element (30) from a list
    // @ReturnType: void
    // -------------------------
    public static void removeElementFromList(){
        List<Integer> myList = new List<Integer>{10, 20, 30, 40};
        System.debug('Original List: ' + myList);
        for(Integer i = 0; i < myList.size(); i++){
            if(myList[i] == 30){
                myList.remove(i);
                break;
            }
        }
        System.debug('List after removal of 30: ' + myList);
    }

    // -------------------------
    // Question 10: Check if any subject scored full marks
    // @ReturnType: void
    // -------------------------
    public static void checkSubjectMarks() {
        Map<String, Integer> subjectMarks = new Map<String, Integer>{
            'Maths'   => 90,
            'Science' => 85,
            'English' => 95
        };
        System.debug('Subject Marks: ' + subjectMarks);
        Boolean hasFullMarks = false;
        for (Integer mark : subjectMarks.values()) {
            if (mark == 100) {
                hasFullMarks = true;
                break;
            }
        }
        if (hasFullMarks) {
            System.debug('Yes, at least one subject scored 100.');
        } else {
            System.debug('No, no subject scored 100.');
        }
    }
}