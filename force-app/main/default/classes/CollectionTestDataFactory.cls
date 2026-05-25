/*
 @Name: CollectionTestDataFactory
 @Author: Ankit Kumar
 @Description: Provides test data (Lists, Sets, Maps) for MyCollectionExample class
 @Date: 28/08/2025
 @ReturnType: Returns List, Set, or Map depending on method
*/
public class CollectionTestDataFactory {

    // -------------------------
    // List of cities
    // @ReturnType: List<String>
    // -------------------------
    public static List<String> getCityList(){
        return new List<String>{'Delhi','Jaipur','Agra','Patna','Nagpur'};
    }

    // -------------------------
    // Set of numbers
    // @ReturnType: Set<Integer>
    // -------------------------
    public static Set<Integer> getNumberSet(){
        return new Set<Integer>{10,20,20,30,40,10};
    }

    // -------------------------
    // List of names with duplicates
    // @ReturnType: List<String>
    // -------------------------
    public static List<String> getNameListWithDuplicates(){
        return new List<String>{'Aman', 'Riya', 'Aman', 'Sita', 'Riya'};
    }

    // -------------------------
    // List of numbers for sorting
    // @ReturnType: List<Integer>
    // -------------------------
    public static List<Integer> getNumberList(){
        return new List<Integer>{50,20,70,10};
    }

    // -------------------------
    // Map of country to capital
    // @ReturnType: Map<String, String>
    // -------------------------
    public static Map<String,String> getCountryCapitalMap(){
        return new Map<String,String>{
            'India' => 'New Delhi',
            'Japan' => 'Tokyo',
            'UK'    => 'London'
        };
    }

    // -------------------------
    // Nested Map of countries, cities, and monuments
    // @ReturnType: Map<String, Map<String, List<String>>>
    // -------------------------
    public static Map<String, Map<String, List<String>>> getCountryCityMonumentsMap(){
        Map<String, Map<String, List<String>>> countryMap = new Map<String, Map<String, List<String>>>();

        Map<String, List<String>> indiaCities = new Map<String, List<String>>();
        indiaCities.put('Delhi', new List<String>{'Red Fort', 'Qutub Minar'});
        indiaCities.put('Agra', new List<String>{'Taj Mahal'});
        countryMap.put('India', indiaCities);

        Map<String, List<String>> usCities = new Map<String, List<String>>();
        usCities.put('NYC', new List<String>{'Statue of Liberty'});
        countryMap.put('US', usCities);

        return countryMap;
    }

    // -------------------------
    // Map of student names and marks
    // @ReturnType: Map<String, Integer>
    // -------------------------
    public static Map<String,Integer> getStudentMarksMap(){
        return new Map<String,Integer>{
            'Ankit'  => 70,
            'Amit'   => 90,
            'Pankaj' => 60,
            'Shreya' => 80,
            'Anjali' => 95
        };
    }

    // -------------------------
    // Map of subjects and marks
    // @ReturnType: Map<String, Integer>
    // -------------------------
    public static Map<String,Integer> getSubjectMarksMap(){
        return new Map<String,Integer>{
            'Maths'   => 90,
            'Science' => 85,
            'English' => 95
        };
    }
    
    // -------------------------
    // List of integers for removal test
    // @ReturnType: List<Integer>
    // -------------------------
    public static List<Integer> getListForRemoval(){
        return new List<Integer>{10,20,30,40};
    }
}