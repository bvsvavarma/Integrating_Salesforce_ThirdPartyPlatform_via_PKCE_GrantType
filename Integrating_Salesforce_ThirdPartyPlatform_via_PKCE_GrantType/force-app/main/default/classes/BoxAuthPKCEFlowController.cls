public with sharing class BoxAuthPKCEFlowController {

    public PageReference authenticate(){
        String endPoint = 'https://account.box.com/api/oauth2/authorize/?client_id=4to32vq7kbbe25icy6ozj2kfizdlows4&response_type=code&code_challenge_method=S256&code_challenge=';
        //1. Create Code Verifier
        String codeVerifier = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    
        //2. Encrypt the Code Verefier
        //generateDigest method accepts Blob as input so converting String into Blob
        Blob codeVerifierBlob = Blob.valueOf(codeVerifier);
        Blob cyptoDigest = Crypto.generateDigest('SHA3-256', codeVerifierBlob);  
        
        //3. Encode the Code Verifier
        String afterCryptoDigest = EncodingUtil.base64Encode(cyptoDigest);

        return new PageReference(endPoint);
    }

    public void getAccessToken(){
        String authCode = apexpages.currentPage().getParameters().get('code');
        String clientId= '4to32vqXXXXXXXXXXXXXXXXXXX';
        String clientSecret= 'U83r2mPXXXXXXXXXXXXXXXXXXXXX';
        String codeVerifier= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String redirectUri = 'https://varma6-dev-ed--c.develop.vf.force.com/apex/BoxAuthPKCEFlowSuccess';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.box.com/oauth2/token/');
        request.setMethod('POST');
        String body = 'grant_type=authorization_code' +
                        '&code=' + EncodingUtil.urlEncode(authCode, 'UTF-8') +
                        '&client_id='+EncodingUtil.urlEncode(clientId, 'UTF-8') +
                        '&client_secret='+EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
                        '&redirect_uri='+EncodingUtil.urlEncode(redirectUri, 'UTF-8') +
                        '&code_verifier='+EncodingUtil.urlEncode(codeVerifier, 'UTF-8');
        request.setBody(body);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            System.debug('Access Token: ' + response.getBody());
            Map<String,Object> tokenResponse = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            String accessToken =  (String) tokenResponse.get('access_token');
            String filesList = getFilesFromFolder(accessToken);
            System.debug('filesList: ' + filesList);
        }else{
            System.debug('Auth Failed: ' + response.getBody());
        }
    }

    public String getFilesFromFolder(String accessToken){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.box.com/2.0/folders/315732128667/items/');
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);

        HttpResponse res = http.send(req);
        if(res.getStatusCode() == 200){
            System.debug(res.getBody());
            
        }else{
            System.debug(res.getBody());
        }
        return res.getBody();
        
    }
}