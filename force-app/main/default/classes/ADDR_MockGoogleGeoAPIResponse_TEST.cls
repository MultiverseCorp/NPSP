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
* @description Class that generates mock HTTP responses for Google Geo API
*/
@isTest
public with sharing class ADDR_MockGoogleGeoAPIResponse_TEST implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest req) {
        String singleUSAddressResponse = '{'+
        
        '}';

        String singleInternationalAddressResponse = '{'+
        
        '}';

        String ambiguousAddressResponse = '{'+
        
        '}';

        String invalidRequestResponse = '{\"results\" : [],\"status\" : \"INVALID_REQUEST\"}';
        String overQueryLimitResponse = '{\"results\" : [],\"status\" : \"OVER_QUERY_LIMIT\"}';
        String requestDeniedResponse = '{\"results\" : [],\"status\" : \"REQUEST_DENIED\"}';
        String unknownErrorResponse = '{\"results\" : [],\"status\" : \"UNKNOWN_ERROR\"}';
        String zeroResultsResponse = '{\"results\" : [],\"status\" : \"ZERO_RESULTS\"}';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (req.getEndpoint().contains('401')) {
            res.setStatusCode(401);
            res.setStatus('Not authenticated.');
        } else {
            res.setStatusCode(ADDR_Validator_UTIL.RESPONSE_CODE_SUCCESS);
            res.setStatus(ADDR_Validator_UTIL.RESPONSE_OK);

            if(req.getEndPoint().contains('single-address')) {
                res.setBody(singleUSAddressResponse);
            } else if(req.getEndPoint().contains('international-address')) {
                res.setBody(singleInternationalAddressResponse);
            } else if(req.getEndPoint().contains('ambiguous-address')) {
                res.setBody(ambiguousAddressResponse);
            } else if(req.getEndPoint().contains('invalid-request')) {
                res.setBody(invalidRequestResponse);
            } else if(req.getEndPoint().contains('over-query-limit')) {
                res.setBody(overQueryLimitResponse);
            } else if(req.getEndPoint().contains('request-denied')) {
                res.setBody(requestDeniedResponse);
            } else if(req.getEndPoint().contains('unknown-error')) {
                res.setBody(unknownErrorResponse);
            } else if(req.getEndPoint().contains('zero-results')) {
                res.setBody(zeroResultsResponse);
            }
        }
        return res;
    }
}