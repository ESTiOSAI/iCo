//
//  ChartViewModel+Dummy.swift
//  AIProject
//
//  Created by 강민지 on 8/7/25.
//

import Foundation

// MARK: - Dummy Data Generator
extension ChartViewModel {
    /// 지정된 시간 동안, 일정 간격으로 "항상 같은 모양"의 차트 더미 데이터를 생성
    static func makeDummyPrices(hours: Double, samplingInterval: TimeInterval) -> [CoinPrice] {
        // 현재 시간을 샘플 간격에 맞춰 고정 (항상 같은 시각 기준에서 시작)
        let nowSeconds = Date().timeIntervalSince1970
        let fixedNowSeconds = floor(nowSeconds / samplingInterval) * samplingInterval
        let now = Date(timeIntervalSince1970: fixedNowSeconds)

        // 총 샘플 개수와 시작 시각
        let totalSeconds = hours * 3600
        let sampleCount = max(1, Int(totalSeconds / samplingInterval))
        let startDate = now.addingTimeInterval(-totalSeconds)

        // 항상 같은 난수 시퀀스를 만들기 위한 내부 값
        var randomSeed: UInt64 = 2025
        @inline(__always) func randomUnit() -> Double {
            // 0~1 사이 값 고정 생성 (항상 같은 결과)
            randomSeed &+= 0x9E3779B97F4A7C15
            var tmp = randomSeed
            tmp = (tmp ^ (tmp >> 30)) &* 0xBF58476D1CE4E5B9
            tmp = (tmp ^ (tmp >> 27)) &* 0x94D049BB133111EB
            let r = tmp ^ (tmp >> 31)
            return Double(r & 0x1F_FFFF_FFFF_FFFF) / Double(0x1F_FFFF_FFFF_FFFF)
        }
        @inline(__always) func randomNoise(_ range: Double) -> Double {
            // -range ~ +range 사이 값
            (randomUnit() - 0.5) * 2.0 * range
        }

        // 기본 가격과 파동 크기 설정 (단순 시각용)
        let basePrice = 100.0
        let bigWaveHeight = 0.8      // 큰 파동 세기
        let bigWavePeriod = 24.0     // 큰 파동 주기
        let smallWaveHeight = 0.35   // 작은 파동 세기
        let smallWavePeriod = 7.0    // 작은 파동 주기
        let priceJitter = 0.35       // 매번 조금씩 흔들림
        let wickJitter = 0.45        // 꼬리 길이 흔들림
        let minWickLength = 0.10     // 최소 꼬리 길이

        var prices: [CoinPrice] = []
        prices.reserveCapacity(sampleCount)

        var currentTime = startDate
        var lastClose = basePrice

        for i in 0..<sampleCount {
            // 파동 + 작은 흔들림
            let wave = bigWaveHeight * sin(Double(i) * (2 * .pi / bigWavePeriod))
                     + smallWaveHeight * cos(Double(i) * (2 * .pi / smallWavePeriod))
            let stepChange = randomNoise(priceJitter)

            let open = lastClose
            let close = lastClose + stepChange + wave * 0.04

            var high = max(open, close) + max(minWickLength, abs(randomNoise(wickJitter)))
            var low  = min(open, close) - max(minWickLength, abs(randomNoise(wickJitter)))

            // 꼬리값이 뒤집히지 않게 보정
            if high < max(open, close) { high = max(open, close) + minWickLength }
            if low  > min(open, close) { low  = min(open, close) - minWickLength }

            let tradeVolume = 120_000_000.0 + Double(i % 31) * 1_000_000.0 + randomNoise(500_000.0)

            prices.append(
                CoinPrice(
                    date: currentTime,
                    open: open,
                    high: high,
                    low: low,
                    close: close,
                    trade: tradeVolume,
                    index: i
                )
            )

            currentTime = currentTime.addingTimeInterval(samplingInterval)
            lastClose = close
        }

        return prices
    }
}
