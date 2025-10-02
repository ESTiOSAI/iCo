//
//  ChatBotFAQ.swift
//  iCo
//
//  Created by 강대훈 on 10/1/25.
//

import Foundation

enum ChatBotFAQ: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case whatIsBlockchain = "블록체인이 뭐예요?"
    case bitcoinVsEthereum = "비트코인과 이더리움은 뭐가 달라요?"
    case howPriceDetermined = "코인 시세는 어떻게 결정돼요?"
    case exchangeVsWallet = "거래소랑 지갑은 뭐가 달라요?"
    case whatIsKimchiPremium = "김치 프리미엄(김프)이 뭔가요?"
}
