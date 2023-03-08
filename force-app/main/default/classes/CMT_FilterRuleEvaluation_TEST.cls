/*
    Copyright (c) 2018, Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2018
* @group Custom Metadata Types
* @description Tests for CMT Filter Rule related actions
*/
@isTest(IsParallel=true)
private class CMT_FilterRuleEvaluation_TEST {

    private static Id filterGroupId1, filterGroupId2, filterGroupId3, filterGroupId4, filterGroupId5, filterGroupId6, filterGroupId7;
    private static Date closeDate = Date.Today().toStartOfMonth().addDays(1);

    /**
     * @description Because unit tests cannot actually insert Custom Metadata Types and there's no real way to know
     * exactly what's in the CMT objects, we can use this method to mock the contents of the cached MDT queries
     * for the unit tests
     */
    private static void mockFilterCMTValues() {

        filterGroupId1 = CMT_UnitTestData_TEST.getNewRecordId();
        filterGroupId2 = CMT_UnitTestData_TEST.getNewRecordId();
        filterGroupId3 = CMT_UnitTestData_TEST.getNewRecordId();
        filterGroupId4 = CMT_UnitTestData_TEST.getNewRecordId();
        filterGroupId5 = CMT_UnitTestData_TEST.getNewRecordId();
        filterGroupId6 = CMT_UnitTestData_TEST.getNewRecordId();
        filterGroupId7 = CMT_UnitTestData_TEST.getNewRecordId();

        String closedWonStage = UTIL_UnitTestData_TEST.getClosedWonStage();
        String donationRTId = UTIL_RecordTypes.getRecordTypeIdForGiftsTests(Opportunity.SObjectType);
        String anotherId = UTIL_RecordTypes.getRecordTypeIdForMembershipTests(Opportunity.SObjectType);
        RecordType rtDonation = [SELECT DeveloperName FROM RecordType WHERE Id = :donationRTId LIMIT 1];

        String filterGroupsJSON = '[' +
            ']';

        String closeDateString = Datetime.newInstance(closeDate, Time.newInstance(12,0,0,0)).format('YYYY-MM-dd');

        String filterRulesJSON = '[' +
            ']';

        // Count the number of records that there should be in the group and rule JSON strings
        Integer numGroups = filterGroupsJSON.countMatches('Filter_Group__mdt');
        Integer numRules = filterRulesJSON.countMatches('Filter_Rule__mdt');

        // Deserialize the JSON strings into the FilterGroup and FilterRule MDT types respectively
        CMT_FilterRule_SEL.cachedFilterGroups = (List<Filter_Group__mdt>)JSON.deserialize(
                filterGroupsJSON, List<Filter_Group__mdt>.class);
        CMT_FilterRule_SEL.cachedFilterRules = (List<Filter_Rule__mdt>)JSON.deserialize(
                filterRulesJSON, List<Filter_Rule__mdt>.class);

        // Validate that the expected number of Filter Groups and Filter Rule records were deserialized.
        System.AssertEquals(numGroups, CMT_FilterRule_SEL.cachedFilterGroups.size(),
            'There should have been ' + numGroups + ' Filter_Group__mdt records deserialized');
        System.AssertEquals(numRules, CMT_FilterRule_SEL.cachedFilterRules.size(),
            'There should have been ' + numRules + ' Filter_Rule__mdt records deserialized');
    }

    /**
     * @description test the evaluation method to process a given SObject against a FilterGroup
     */
    @IsTest static void test_evaluateFilterRules() {
        mockFilterCMTValues();

        Contact con = UTIL_UnitTestData_TEST.getContact();
        insert con;
        con = [SELECT Id, AccountId, FirstName, LastName FROM Contact LIMIT 1];

        Opportunity opp = new Opportunity (
                Name = 'Test Opp ' + con.FirstName + con.LastName,
                Amount = 1000,
                CloseDate = closeDate,
                StageName = UTIL_UnitTestData_TEST.getClosedWonStage(),
                Primary_Contact__c = con.Id,
                RecordTypeId = UTIL_RecordTypes.getRecordTypeIdForGiftsTests(Opportunity.sObjectType),
                NextStep = 'Test Next Step'
        );
        insert opp;
        System.AssertEquals(1, [SELECT Count() FROM OpportunityContactRole]);

        Partial_Soft_Credit__c psc = new Partial_Soft_Credit__c(
                Opportunity__c = opp.Id,
                Contact__c = con.Id,
                Role_Name__c = CAO_Constants.OCR_DONOR_ROLE,
                Amount__c = opp.Amount
        );
        insert psc;

        // Query the Opportunity and the child OCR and Payment records to use in the evaluation
        List<Id> contactIds = new List<Id>();
        String soql = CRLP_Query_SEL.buildDetailObjectQueryForRollup(Opportunity.SObjectType,
                new List<SObjectType>{OpportunityContactRole.SObjectType, npe01__OppPayment__c.SObjectType, Partial_Soft_Credit__c.SObjectType});
        opp = Database.query(soql);
        System.assertEquals(0, opp.OpportunityContactRoles.size());

        contactIds = new List<Id>{con.Id};
        opp = Database.query(soql);
        System.assertEquals(1, opp.OpportunityContactRoles.size());

        Test.startTest();

         System.Assert(CMT_FilterRuleEvaluation_SVC.evaluateFilterGroup(new List<SObject>{
                 opp
         }, filterGroupId1));
         System.Assert(CMT_FilterRuleEvaluation_SVC.evaluateFilterGroup(new List<SObject>{
                 opp
         }, filterGroupId2));
         System.Assert(CMT_FilterRuleEvaluation_SVC.evaluateFilterGroup(new List<SObject>{
                 opp
         }, filterGroupId3));

         System.Assert(CMT_FilterRuleEvaluation_SVC.evaluateFilterGroup(
                 new List<SObject>{
                         opp, opp.OpportunityContactRoles[0]}, filterGroupId2));
         System.Assert(CMT_FilterRuleEvaluation_SVC.evaluateFilterGroup(
                 new List<SObject>{
                         opp, opp.OpportunityContactRoles[0]}, filterGroupId5));
         System.Assert(CMT_FilterRuleEvaluation_SVC.evaluateFilterGroup(
                 new List<SObject>{
                         opp, opp.OpportunityContactRoles[0]}, filterGroupId6));
         System.Assert(CMT_FilterRuleEvaluation_SVC.evaluateFilterGroup(
                 new List<SObject>{
                         opp, opp.OpportunityContactRoles[0]}, filterGroupId7));

        // TODO Add more tests
    }

}