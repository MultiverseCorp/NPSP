/*
 * Copyright (c) 2020, Salesforce.org
 *     All rights reserved.
 *
 *     Redistribution and use in source and binary forms, with or without
 *     modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of Salesforce.org nor the names of
 *       its contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.
 *
 *     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *     "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *     LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 *     FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *     COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 *     INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 *     BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 *     CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 *     LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 *     ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *     POSSIBILITY OF SUCH DAMAGE.
 */
@IsTest
public class ElevateBatchServiceValidRequest extends ElevateBatchService {
    ElevateBatchItemType batchItemType;
    String paymentMethod;

    private String oneTimeResponse {
        get {
            if (paymentMethod == 'CARD') {
                return oneTimeCardSuccessResponse();
            } else {
                return oneTimeACHSuccessResponse();
            }
        }
        set;
    }
    private String commitmentResponse {
        get {
            if (paymentMethod == 'CARD') {
                return commitmentCardSuccessResponse();
            } else {
                return commitmentACHSuccessResponse();
            }
        }
        set;
    }

    public ElevateBatchServiceValidRequest(){}
    public ElevateBatchServiceValidRequest(ElevateBatchItemType batchItemType, String paymentMethod){
        this.batchItemType = batchItemType;
        this.paymentMethod = paymentMethod;
    }

    public override ElevateBatchItem addToElevateBatch(ElevateCreateBatchItemRequestDTO createBatchItemRequestDTO,
                                                       String elevateBatchId) {
        ElevateBatchItemCreateResponse giftResponse;

        if (batchItemType == ElevateBatchItemType.ONE_TIME) {
            giftResponse = ElevateBatchItemCreateResponse.parse(oneTimeResponse);
        } else {
            giftResponse = ElevateBatchItemCreateResponse.parse(commitmentResponse);
        }

        return new ElevateBatchItem(giftResponse);
    }

    public override ElevateBatch createElevateBatch() {
        ElevateBatchResponse elevateBatchResponse = ElevateBatchResponse.parse(createBatchSuccessResponse());
        return new ElevateBatch(elevateBatchResponse);
    }

    public override UTIL_Http.Response sendRemoveRequest(String elevatePaymentId, String elevateBatchId) {
        return (UTIL_Http.Response) JSON.deserialize(removeBatchItemSuccessResponse(), UTIL_Http.Response.class);
    }

    private static String removeBatchItemSuccessResponse() {
        return '{\n' +
                '"statusCode": "204",\n' +
                '"status": "Remove successful"\n' +
                '}';
    }

    private static String oneTimeCardSuccessResponse() {
        return '{\n' +
                
                '}';
    }

    private static String oneTimeACHSuccessResponse() {
        return '{\n' +
                
                '}';
    }

    private static String commitmentCardSuccessResponse() {
        return '{\n' +
                
                '}';
    }

    private static String commitmentACHSuccessResponse() {
        return '{\n' +
                
                '}';
    }

    private static String createBatchSuccessResponse() {
        return '{\n' +
                
                '}';
    }
}