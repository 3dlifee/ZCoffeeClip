//
//  ZCoffeeSwiftUIView.swift
//  ZCoffeeClip
//
//  Created by Mario Fernandes on 18/06/2021.
//

import SwiftUI
import swift_algorand_sdk

struct ZCoffeeSwiftUIView: View {
   
    @State private var assetRewardState = false
    @State var isLoading = false
    let transactionSuccedImage = "orderPlaced"
    let transactionFailImage = "orderfail"
    @State private var compileVerified = false
    @State private var transactionIsShowing = false
    @State var complieHash:String = "Hash"
    @State var clearStateProgramSource = "compile.teal"
    
    var ALGOD_API_ADDR="https://testnet-algorand.api.purestake.io/ps2"
    var ALGOD_API_TOKEN="G------------------------------"
    var ALGOD_API_PORT=""
    
    var body: some View {
        
        VStack {
            
            Image("appclippBuy")
                .resizable()
            
            HStack() {
                
                Button(action: {
                    
                    self.tealCompile()
                    
                }) {
                    Image("compile")
                        .padding(.bottom)
                    
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    
                    self.createApplication()
                    self.startHolding()
                }) {
                    Image("buyBtn")
                    
                }
                
                .sheet(isPresented:  $assetRewardState) {
                    VStack(){
                        if self.transactionIsShowing == true {
                            
                            Image(transactionSuccedImage)
                            
                            Button("Dismiss",
                                   action: {  self.assetRewardState.toggle() })
                            
                        } else  if self.transactionIsShowing == false {
                            
                            
                            Image(transactionFailImage)
                            
                            Button("Dismiss",
                                   action: {  self.assetRewardState.toggle() })
                            
                        }
                    }
                }
                
                .disabled(compileVerified == false)
                .opacity(compileVerified == false ? 0.6 : 1)
                
            }
            .padding(.horizontal) //hstack
            
            Text(complieHash)
                .foregroundColor(.black)
                .padding(.bottom, 50.0)
            
            if isLoading {
                ZStack {
                    Color(.white)
                        .ignoresSafeArea()
                        .opacity(0.9)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .scaleEffect(3)
                }
                .frame(height: 90.0)
            }
            
            Spacer()
        }
        
        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        .background(Color.white)
        
        
    }
    
    func startHolding(){
        isLoading = true

    }
    
    func startHoldingOff(){
        isLoading = false

    }
 
    
    public func tealCompile(){
        
        let algodClient=AlgodClient(host: ALGOD_API_ADDR, port: ALGOD_API_PORT, token: ALGOD_API_TOKEN)
        algodClient.set(key: "X-API-KeY")
        
        let source:[Int8] = ZCoffeeSwiftUIView.loadSampleTeal(resource: clearStateProgramSource)
        
        algodClient.tealCompile().source(source: source).execute(){compileResponse in
            if(compileResponse.isSuccessful){
                print(compileResponse.data?.hash as Any)
                print(compileResponse.data?.result as Any)
                self.compileVerified = true
                self.complieHash = "Result: \(compileResponse.data!.result!)\n Hash: \(compileResponse.data!.hash!)"
                
            }else{
                print(compileResponse.errorMessage!)
                complieHash = compileResponse.errorMessage!
            }
        }
        print(source)
    }
    
    public static func loadSampleTeal(resource:String)  -> [Int8] {
        let configURL = Bundle.main.path(forResource: resource, ofType: "txt")
        let contensts = try! String(contentsOfFile: configURL!.description)
        let jsonData = contensts.data(using: .utf8)!
        
        let  data = CustomEncoder.convertToInt8Array(input: Array(jsonData))
        print(data)
        return data
    }
    
    func createApplication(){
        let algodClient=AlgodClient(host: ALGOD_API_ADDR, port: ALGOD_API_PORT, token: ALGOD_API_TOKEN)
        algodClient.set(key: "X-API-KeY")
        
        var stxns:[SignedTransaction] = Array()
        
        let mnemonic = "star star star star star star star star star star star star star star star star star star star star star star star star star"
        
        let mnemonic2 = "fork fork fork fork fork fork fork fork fork fork fork fork fork v fork fork fork fork fork fork fork fork fork fork fork fork"
        
        let account2 = try! Account(mnemonic2)
        let account = try! Account(mnemonic)
        let senderAddress = account.getAddress()
        let receiverAddress2 = account2.getAddress()
        
        algodClient.transactionParams().execute(){ paramResponse in
            if(!(paramResponse.isSuccessful)){
                print(paramResponse.errorDescription!);
                print("passou")
                return;
            }
            
            let program:[Int8] = CustomEncoder.convertToInt8Array(input: CustomEncoder.convertBase64ToByteArray(data1: "ASABASI="))
            
            let lsig = try! LogicsigSignature(logicsig: program)
            
            _ = try! account.signLogicsig(lsig: lsig)
            
            let tx = try? Transaction.paymentTransactionBuilder().setSender(senderAddress)
                .amount(1000000)
                .receiver(receiverAddress2)
                .note("draw algo with logic signature".bytes)
                .suggestedParams(params: paramResponse.data!)
                .build()
            
            let stx = Account.signLogicsigTransaction(lsig: lsig, tx: tx!)
            stxns.append(stx)
            
            let encodedTrans:[Int8]=CustomEncoder.encodeToMsgPack(stx)
            
            algodClient.rawTransaction().rawtxn(rawtaxn: encodedTrans).execute(){
                response in
                if(response.isSuccessful){
                    
                    print(response.data!.txId)
                    print("Created")
                    self.waitForTransaction(txId:response.data!.txId)
                    
                }else{
                    print(response.errorDescription!)
                    print("Failed")
                }
            }
        }
    }
    
    
    
    //-----
    func waitForTransaction(txId:String) {
        
        let algodClient=AlgodClient(host: ALGOD_API_ADDR, port: ALGOD_API_PORT, token: ALGOD_API_TOKEN)
        
        algodClient.set(key: "X-API-KeY")
        var confirmedRound: Int64?=0
        
        algodClient.pendingTransactionInformation(txId:txId).execute(){
            pendingTransactionResponse in
            if(pendingTransactionResponse.isSuccessful){
                confirmedRound=pendingTransactionResponse.data!.confirmedRound
                
                if(confirmedRound != nil && confirmedRound! > 0){
                    print("confirmedRound")
                    
                    self.transactionIsShowing = true
                    self.startHoldingOff()
                    if transactionIsShowing == true {
                        DispatchQueue.main.async {
                            print(transactionIsShowing)
                            self.assetRewardState = true
                            
                        }
                    }
                }else{
                    self.waitForTransaction(txId: txId)
                }
            }else{
                print(pendingTransactionResponse.errorDescription!)
                
                self.transactionIsShowing = false
                self.startHoldingOff()
                if transactionIsShowing == false {
                    DispatchQueue.main.async {
                        print("fail")
                        self.assetRewardState = true
                        
                    }
                }
                confirmedRound=12000;
            }
        }
    }
       
    
}

struct ZCoffeeSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ZCoffeeSwiftUIView()
    }
}
