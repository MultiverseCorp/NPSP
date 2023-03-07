/*
    Copyright (c) 2014, Salesforce.org
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
* @date 2014
* @group Address Management
* @description test class that provides address validation/normalization services
* through the Cicero API.
 */

@isTest(IsParallel=True)
public with sharing class ADDR_Cicero_TEST {

    /*********************************************************************************************************
    * @description a fake http response from Cicero for test code
    */
    private static string strResponseTest =
'{'+
'}';

    /*********************************************************************************************************
    * @description returns the HTTP Response from the HTTP Request for Cicero.
    * @param req the HTTP Request object
    * *returns HTTPResponse
    */
    public static HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(strResponseTest);
        res.setStatusCode(200);
        return res;
    }

    /*********************************************************************************************************
    * @description Tests validating a single address.
    */
	private static testmethod void singleValidAddr() {
        list<Address__c> listAddr = new list<Address__c>();
        Address__c addr = new Address__c();
        addr.MailingStreet__c = '1 market st #300';
        addr.MailingCity__c = 'san francisco';
        addr.MailingState__c = 'ca';
        addr.MailingPostalCode__c = '94105-1234';
        listAddr.add(addr);

        ADDR_Cicero_Validator cicero = new ADDR_Cicero_Validator();
        Addr_Verification_Settings__c settings = new Addr_Verification_Settings__c();
        settings.Auth_Token__c = 'foo';  // we need a fake token or we won't validate
        settings.Address_Verification_Endpoint__c = 'bar';
        List<Address__c> listAddrVerified = cicero.verifyRecords(listAddr, settings);
        system.assertEquals(1, listAddrVerified.size());
        //system.assertNotEquals(null, listAddrVerified[0].Pre_Verification_Address__c);
        system.assertEquals(true, listAddrVerified[0].Verified__c);
        system.assertEquals('1 Market St #300', listAddrVerified[0].MailingStreet__c);
        system.assertEquals('San Francisco', listAddrVerified[0].MailingCity__c);
        system.assertEquals('CA', listAddrVerified[0].MailingState__c);
        system.assertEquals('94105-1234', listAddrVerified[0].MailingPostalCode__c);
        system.assertEquals('17', listAddrVerified[0].State_Lower_District__c);
        system.assertEquals('11', listAddrVerified[0].State_Upper_District__c);

	}

    /*********************************************************************************************************
    * @description Tests that user can choose to not have the Cicero response overwrite their address.
    */
    private static testmethod void doesNotOverwriteAddr() {
        list<Address__c> listAddr = new list<Address__c>();
        Address__c addr = new Address__c();
        addr.MailingStreet__c = '';
        addr.MailingCity__c = 'san francisco';
        addr.MailingState__c = 'ca';
        addr.MailingPostalCode__c = '94105';
        listAddr.add(addr);

        ADDR_Cicero_Validator cicero = new ADDR_Cicero_Validator();
        Addr_Verification_Settings__c settings = new Addr_Verification_Settings__c();
        settings.Auth_Token__c = 'foo';  // we need a fake token or we won't validate
        settings.Address_Verification_Endpoint__c = 'bar';
        settings.Prevent_Address_Overwrite__c = true;
        List<Address__c> listAddrVerified = cicero.verifyRecords(listAddr, settings);

        system.assertEquals(1, listAddrVerified.size());
        system.assertEquals(true, listAddrVerified[0].Verified__c);
        system.assertEquals('', listAddrVerified[0].MailingStreet__c);
        system.assertEquals('san francisco', listAddrVerified[0].MailingCity__c);
        system.assertEquals('ca', listAddrVerified[0].MailingState__c);
        system.assertEquals('94105', listAddrVerified[0].MailingPostalCode__c);
        system.assertEquals('17', listAddrVerified[0].State_Lower_District__c);
        system.assertEquals('11', listAddrVerified[0].State_Upper_District__c);

    }
    /*********************************************************************************************************
    * @description Tests that user can allow Cicero response to overwrite the provided address.
    */
    private static testmethod void doesOverwriteAddr() {
        list<Address__c> listAddr = new list<Address__c>();
        Address__c addr = new Address__c();
        addr.MailingStreet__c = '1 market';
        addr.MailingCity__c = '';
        addr.MailingState__c = 'ca';
        addr.MailingPostalCode__c = '94105';
        listAddr.add(addr);

        ADDR_Cicero_Validator cicero = new ADDR_Cicero_Validator();
        Addr_Verification_Settings__c settings = new Addr_Verification_Settings__c();
        settings.Auth_Token__c = 'foo';  // we need a fake token or we won't validate
        settings.Address_Verification_Endpoint__c = 'bar';
        settings.Prevent_Address_Overwrite__c = false;
        List<Address__c> listAddrVerified = cicero.verifyRecords(listAddr, settings);

        system.assertEquals(1, listAddrVerified.size());
        system.assertEquals(true, listAddrVerified[0].Verified__c);
        system.assertEquals('1 Market St #300', listAddrVerified[0].MailingStreet__c);
        system.assertEquals('San Francisco', listAddrVerified[0].MailingCity__c);
        system.assertEquals('CA', listAddrVerified[0].MailingState__c);
        system.assertEquals('94105', listAddrVerified[0].MailingPostalCode__c);
        system.assertEquals('17', listAddrVerified[0].State_Lower_District__c);
        system.assertEquals('11', listAddrVerified[0].State_Upper_District__c);

    }
}