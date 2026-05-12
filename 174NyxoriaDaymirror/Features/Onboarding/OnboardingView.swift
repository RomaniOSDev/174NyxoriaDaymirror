//
//  OnboardingView.swift
//  174NyxoriaDaymirror
//

import SwiftUI

// MARK: - Illustrations (gradient wash + Canvas, single spring — no TimelineView)

private struct OnboardingIllustrationOne: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appPrimary.opacity(0.2),
                    Color.appSurface.opacity(0.35),
                    Color.appAccent.opacity(0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Canvas { context, size in
                let center = CGPoint(x: size.width * 0.5, y: size.height * 0.52)
                var flower = Path()
                for index in 0 ..< 6 {
                    let angle = CGFloat(index) / 6 * .pi * 2
                    let petal = CGRect(
                        x: center.x + cos(angle) * 18 - 22,
                        y: center.y + sin(angle) * 18 - 40,
                        width: 44,
                        height: 80
                    )
                    flower.addRoundedRect(
                        in: petal,
                        cornerSize: CGSize(width: 22, height: 36),
                        transform: CGAffineTransform(rotationAngle: angle)
                    )
                }
                context.fill(flower, with: .color(Color.appAccent.opacity(0.82)))
                let core = Path(ellipseIn: CGRect(x: center.x - 28, y: center.y - 28, width: 56, height: 56))
                context.fill(core, with: .color(Color.appPrimary.opacity(1)))
                context.stroke(core, with: .color(Color.white.opacity(0.22)), lineWidth: 2)
            }
            .drawingGroup(opaque: false)
        }
        .frame(height: 232)
        .scaleEffect(animate ? 1 : 0.78)
        .opacity(animate ? 1 : 0.3)
        .animation(.spring(response: 0.52, dampingFraction: 0.68).delay(0.04), value: animate)
        .onAppear { animate = true }
    }
}

private struct OnboardingIllustrationTwo: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appAccent.opacity(0.14),
                    Color.appSurface.opacity(0.32),
                    Color.appPrimary.opacity(0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Canvas { context, size in
                let center = CGPoint(x: size.width * 0.5, y: size.height * 0.48)
                for index in 0 ..< 5 {
                    let offset = CGFloat(index) * 22 - 44
                    let star = Path { path in
                        let p = CGPoint(x: center.x + offset, y: center.y - CGFloat(index) * 10)
                        path.move(to: CGPoint(x: p.x, y: p.y - 22))
                        path.addLine(to: CGPoint(x: p.x + 8, y: p.y - 6))
                        path.addLine(to: CGPoint(x: p.x + 24, y: p.y - 6))
                        path.addLine(to: CGPoint(x: p.x + 10, y: p.y + 8))
                        path.addLine(to: CGPoint(x: p.x + 16, y: p.y + 26))
                        path.addLine(to: CGPoint(x: p.x, y: p.y + 16))
                        path.addLine(to: CGPoint(x: p.x - 16, y: p.y + 26))
                        path.addLine(to: CGPoint(x: p.x - 10, y: p.y + 8))
                        path.addLine(to: CGPoint(x: p.x - 24, y: p.y - 6))
                        path.addLine(to: CGPoint(x: p.x - 8, y: p.y - 6))
                        path.closeSubpath()
                    }
                    context.fill(star, with: .color(Color.appPrimary.opacity(0.94 - Double(index) * 0.12)))
                    context.stroke(star, with: .color(Color.white.opacity(0.15 - Double(index) * 0.02)), lineWidth: 1)
                }
            }
            .drawingGroup(opaque: false)
        }
        .frame(height: 232)
        .scaleEffect(animate ? 1 : 0.78)
        .opacity(animate ? 1 : 0.3)
        .animation(.spring(response: 0.52, dampingFraction: 0.68).delay(0.04), value: animate)
        .onAppear { animate = true }
    }
}

private struct OnboardingIllustrationThree: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appSurface.opacity(0.4),
                    Color.appPrimary.opacity(0.14),
                    Color.appAccent.opacity(0.14)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Canvas { context, size in
                let base = CGPoint(x: size.width * 0.5, y: size.height * 0.72)
                var stem = Path()
                stem.move(to: base)
                stem.addQuadCurve(to: CGPoint(x: base.x + 60, y: base.y - 120), control: CGPoint(x: base.x + 20, y: base.y - 60))
                context.stroke(stem, with: .color(Color.appAccent.opacity(0.88)), lineWidth: 7)
                let leaf1 = Path(ellipseIn: CGRect(x: base.x - 70, y: base.y - 90, width: 70, height: 36))
                context.fill(leaf1, with: .color(Color.appSurface.opacity(0.98)))
                context.stroke(leaf1, with: .color(Color.appAccent.opacity(0.35)), lineWidth: 1)
                let leaf2 = Path(ellipseIn: CGRect(x: base.x + 10, y: base.y - 110, width: 64, height: 34))
                context.fill(leaf2, with: .color(Color.appAccent.opacity(0.42)))
                let creature = Path(ellipseIn: CGRect(x: base.x + 45, y: base.y - 150, width: 80, height: 64))
                context.fill(creature, with: .color(Color.appPrimary.opacity(1)))
                context.stroke(creature, with: .color(Color.white.opacity(0.2)), lineWidth: 1.5)
            }
            .drawingGroup(opaque: false)
        }
        .frame(height: 232)
        .scaleEffect(animate ? 1 : 0.78)
        .opacity(animate ? 1 : 0.3)
        .animation(.spring(response: 0.52, dampingFraction: 0.68).delay(0.04), value: animate)
        .onAppear { animate = true }
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var page = 0

    private let pageTitles = ["Nurture Creatures", "Collect Stars", "Begin Your Journey"]
    private let pageDetails = [
        "Tap plants to help your creature grow.",
        "Earn STARS for each thoughtful session.",
        "Open Home to track your rhythm and bloom every path."
    ]

    var body: some View {
        ZStack {
            LayeredBackgroundView()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(0 ..< 3, id: \.self) { index in
                        pageContent(index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                bottomChrome
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
    }

    private var bottomChrome: some View {
        VStack(spacing: 14) {
            DotPageIndicator(count: 3, current: page)

            if page < 2 {
                Button {
                    HapticFeedback.buttonTap()
                    progressStore.completeOnboarding()
                } label: {
                    Text("Skip intro")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }

            Button(action: advance) {
                Text(page == 2 ? "Get Started" : "Next")
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryProminentButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 22)
        .appElevatedPlate(cornerRadius: 26, elevation: .floating)
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private func pageContent(index: Int) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                stepChip(step: index + 1, total: 3)
                    .padding(.top, 8)

                onboardingIllustration(for: index)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 8)
                    .appElevatedPlate(cornerRadius: 26, elevation: .lifted)

                VStack(alignment: .leading, spacing: 12) {
                    Text(pageTitles[index])
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(pageDetails[index])
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appElevatedPlate(cornerRadius: 22, elevation: .soft)

                Spacer(minLength: 140)
            }
            .padding(.horizontal, 20)
        }
    }

    @ViewBuilder
    private func onboardingIllustration(for index: Int) -> some View {
        switch index {
        case 0:
            OnboardingIllustrationOne()
        case 1:
            OnboardingIllustrationTwo()
        default:
            OnboardingIllustrationThree()
        }
    }

    private func stepChip(step: Int, total: Int) -> some View {
        Text("STEP \(step) · \(total)")
            .font(.caption.weight(.bold))
            .tracking(1.4)
            .foregroundStyle(Color.appTextSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .appElevatedPlate(cornerRadius: 14, elevation: .muted, mutedRim: true)
    }

    private func advance() {
        HapticFeedback.buttonTap()
        if page < 2 {
            withAnimation(.easeInOut(duration: 0.28)) {
                page += 1
            }
        } else {
            HapticFeedback.majorAction()
            progressStore.completeOnboarding()
        }
    }
}
