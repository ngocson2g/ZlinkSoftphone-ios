/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
 *
 * This file is part of linphone-iphone
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import SwiftUI

struct ThirdPartySipAccountLoginFragment: View {
	
	@ObservedObject private var coreContext = CoreContext.shared
	@ObservedObject var accountLoginViewModel: AccountLoginViewModel
	
	var onBackPressed: (() -> Void)?
	
	@StateObject private var keyboard = KeyboardResponder()
	
	@Environment(\.dismiss) var dismiss
	
	@State private var isSecured = true
    @State private var advancedSettingsIsOpen = false
	@State private var isShowOutboundProxyPopup = false
	
	@FocusState var isNameFocused: Bool
	@FocusState var isPasswordFocused: Bool
	@FocusState var isDomainFocused: Bool
	@FocusState var isDisplayNameFocused: Bool
	@FocusState var isAuthIdFocused: Bool
    @FocusState var isSipProxyUrlFocused: Bool
	@FocusState var isOutboundProxyFocused: Bool
	
	var body: some View {
		ZStack {
			FullScreenParticlesEffect()
				.ignoresSafeArea()
			
			VStack {
				Spacer()
				AnimatedBlueBottomBand()
			}
			.ignoresSafeArea()
			
			GeometryReader { geometry in
				ScrollViewReader { proxy in
					ZStack {
						if #available(iOS 16.4, *) {
							ScrollView(.vertical) {
								innerScrollView(geometry: geometry)
						}
						.scrollBounceBehavior(.basedOnSize)
						.onChange(of: isAuthIdFocused) { field in
							if field {
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
									proxy.scrollTo(2, anchor: .top)
								}
							}
						}
						.onChange(of: isOutboundProxyFocused) { field in
							if field {
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
									proxy.scrollTo(2, anchor: .top)
								}
							}
						}
					} else {
						ScrollView(.vertical) {
							innerScrollView(geometry: geometry)
						}
						.onChange(of: isAuthIdFocused) { field in
							if field {
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
									proxy.scrollTo(2, anchor: .top)
								}
							}
						}
						.onChange(of: isOutboundProxyFocused) { field in
							if field {
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
									proxy.scrollTo(2, anchor: .top)
								}
							}
						}
					}
					
					if isShowOutboundProxyPopup {
						PopupView(
							isShowPopup: $isShowOutboundProxyPopup,
							title: Text("manage_account_outbound_proxy"),
							content: Text("manage_account_dialog_outbound_proxy_help_message"),
							titleFirstButton: nil,
							actionFirstButton: {},
							titleSecondButton: Text("dialog_understood"),
							actionSecondButton: { self.isShowOutboundProxyPopup.toggle() },
							titleThirdButton: nil,
							actionThirdButton: {}
						)
						.padding(.bottom, keyboard.currentHeight)
						.background(.black.opacity(0.65))
						.zIndex(3)
						.onTapGesture {
							self.isShowOutboundProxyPopup.toggle()
						}
					}
				}
			}
		}
		}
		.navigationTitle("")
		.navigationBarHidden(true)
		.edgesIgnoringSafeArea(.bottom)
		.edgesIgnoringSafeArea(.horizontal)
	}
	
	func innerScrollView(geometry: GeometryProxy) -> some View {
		VStack {
			ZStack {
				HStack {
					Image("caret-left")
						.renderingMode(.template)
						.resizable()
						.foregroundStyle(Color.grayMain2c500)
						.frame(width: 25, height: 25)
						.padding(.all, 10)
						.onTapGesture {
							withAnimation {
								accountLoginViewModel.domain = ""
								accountLoginViewModel.transportType = "TCP"
								if let onBack = onBackPressed {
									onBack()
								} else {
									dismiss()
								}
							}
						}
					Spacer()
				}
				
				Text("assistant_login_third_party_sip_account")
					.default_text_style_800(styleSize: 20)
			}
			.frame(width: geometry.size.width)
			.padding(.top, 10)
			.padding(.bottom, 5)
			
			Button(action: {
				if let url = URL(string: "https://voip.com.vn/document/getsipacc.html") {
					UIApplication.shared.open(url)
				}
			}) {
				Text("assistant_login_third_party_sip_account_subtitle")
					.default_text_style(styleSize: 14)
					.foregroundStyle(Color.grayMain2c500)
			}
			.padding(.bottom, 20)
			
			VStack(alignment: .leading) {
				// MARK: - Display Name
				Text(String(localized: "sip_address_display_name"))
					.default_text_style_700(styleSize: 15)
					.padding(.bottom, -5)
				
				TextField("sip_address_display_name", text: $accountLoginViewModel.displayName)
					.default_text_style(styleSize: 15)
					.disableAutocorrection(true)
					.autocapitalization(.none)
					.frame(height: 25)
					.padding(.horizontal, 20)
					.padding(.vertical, 15)
					.background(Color.white)
					.cornerRadius(60)
					.overlay(
						RoundedRectangle(cornerRadius: 60)
							.inset(by: 0.5)
							.stroke(isDisplayNameFocused ? Color.orangeMain500 : Color.gray200, lineWidth: 1)
					)
					.padding(.bottom)
					.focused($isDisplayNameFocused)
				
				// MARK: - Username
				Text(String(localized: "username")+"*")
					.default_text_style_700(styleSize: 15)
					.padding(.bottom, -5)
				
				TextField("username", text: $accountLoginViewModel.username)
					.default_text_style(styleSize: 15)
					.disableAutocorrection(true)
					.autocapitalization(.none)
					.frame(height: 25)
					.padding(.horizontal, 20)
					.padding(.vertical, 15)
					.background(Color.white)
					.cornerRadius(60)
					.overlay(
						RoundedRectangle(cornerRadius: 60)
							.inset(by: 0.5)
							.stroke(isNameFocused ? Color.orangeMain500 : Color.gray200, lineWidth: 1)
					)
					.padding(.bottom)
					.focused($isNameFocused)
				
				// MARK: - Password
				Text(String(localized: "password")+"*")
					.default_text_style_700(styleSize: 15)
					.padding(.bottom, -5)
				
				ZStack(alignment: .trailing) {
					Group {
						if isSecured {
							SecureField("password", text: $accountLoginViewModel.passwd)
								.default_text_style(styleSize: 15)
								.frame(height: 25)
								.focused($isPasswordFocused)
						} else {
							TextField("password", text: $accountLoginViewModel.passwd)
								.default_text_style(styleSize: 15)
								.disableAutocorrection(true)
								.autocapitalization(.none)
								.frame(height: 25)
								.focused($isPasswordFocused)
						}
					}
					Button(action: {
						isSecured.toggle()
					}, label: {
						Image(self.isSecured ? "eye-slash" : "eye")
							.renderingMode(.template)
							.resizable()
							.foregroundStyle(Color.grayMain2c500)
							.frame(width: 20, height: 20)
					})
				}
				.padding(.horizontal, 20)
				.padding(.vertical, 15)
				.background(Color.white)
				.cornerRadius(60)
				.overlay(
					RoundedRectangle(cornerRadius: 60)
						.inset(by: 0.5)
						.stroke(isPasswordFocused ? Color.orangeMain500 : Color.gray200, lineWidth: 1)
				)
				.padding(.bottom)
				
				// MARK: - Authentication ID
				Text(String(localized: "authentication_id"))
					.default_text_style_700(styleSize: 15)
					.padding(.bottom, -5)
				
				TextField("authentication_id", text: $accountLoginViewModel.authId)
					.id(1)
					.default_text_style(styleSize: 15)
					.disableAutocorrection(true)
					.autocapitalization(.none)
					.frame(height: 25)
					.padding(.horizontal, 20)
					.padding(.vertical, 15)
					.background(.white)
					.cornerRadius(60)
					.overlay(
						RoundedRectangle(cornerRadius: 60)
							.inset(by: 0.5)
							.stroke(isAuthIdFocused ? Color.orangeMain500 : Color.gray200, lineWidth: 1)
					)
					.focused($isAuthIdFocused)
					.padding(.bottom)
				
				// MARK: - Domain
				Text(String(localized: "sip_address_domain")+"*")
					.default_text_style_700(styleSize: 15)
					.padding(.bottom, -5)
				
				TextField("sip_address_domain", text: $accountLoginViewModel.domain)
					.default_text_style(styleSize: 15)
					.disableAutocorrection(true)
					.autocapitalization(.none)
					.frame(height: 25)
					.padding(.horizontal, 20)
					.padding(.vertical, 15)
					.background(Color.white)
					.cornerRadius(60)
					.overlay(
						RoundedRectangle(cornerRadius: 60)
							.inset(by: 0.5)
							.stroke(isDomainFocused ? Color.orangeMain500 : Color.gray200, lineWidth: 1)
					)
					.padding(.bottom)
					.focused($isDomainFocused)
				
				// MARK: - Register with domain checkbox
				Button(action: {
					accountLoginViewModel.registerEnabled.toggle()
				}) {
					HStack(alignment: .top, spacing: 10) {
						Image(systemName: accountLoginViewModel.registerEnabled ? "checkmark.square.fill" : "square")
							.resizable()
							.frame(width: 22, height: 22)
							.foregroundColor(accountLoginViewModel.registerEnabled ? Color.orangeMain500 : Color.grayMain2c500)
						
						Text("register_with_domain_label")
							.default_text_style(styleSize: 14)
							.foregroundStyle(Color.grayMain2c700)
							.multilineTextAlignment(.leading)
					}
				}
				.padding(.bottom, 15)
				
				// MARK: - Send outbound via
				Text("send_outbound_via_label")
					.default_text_style_700(styleSize: 15)
					.foregroundStyle(Color.orangeMain500)
					.padding(.bottom, 5)
				
				// Radio: domain
				Button(action: {
					accountLoginViewModel.outboundMode = .domain
				}) {
					HStack(spacing: 10) {
						Image(systemName: accountLoginViewModel.outboundMode == .domain ? "largecircle.fill.circle" : "circle")
							.resizable()
							.frame(width: 20, height: 20)
							.foregroundColor(accountLoginViewModel.outboundMode == .domain ? Color.orangeMain500 : Color.grayMain2c500)
						
						Text("outbound_mode_domain")
							.default_text_style(styleSize: 14)
							.foregroundStyle(Color.grayMain2c700)
					}
				}
				.padding(.bottom, 8)
				
				// Radio: proxy Address
				Button(action: {
					accountLoginViewModel.outboundMode = .proxyAddress
				}) {
					HStack(spacing: 10) {
						Image(systemName: accountLoginViewModel.outboundMode == .proxyAddress ? "largecircle.fill.circle" : "circle")
							.resizable()
							.frame(width: 20, height: 20)
							.foregroundColor(accountLoginViewModel.outboundMode == .proxyAddress ? Color.orangeMain500 : Color.grayMain2c500)
						
						Text("outbound_mode_proxy_address")
							.default_text_style(styleSize: 14)
							.foregroundStyle(Color.grayMain2c700)
					}
				}
				.padding(.bottom, 4)
				
				// Proxy address text field (shown when proxyAddress mode is selected)
				if accountLoginViewModel.outboundMode == .proxyAddress {
					TextField("outbound_mode_proxy_address", text: $accountLoginViewModel.outboundProxy)
						.id(3)
						.default_text_style(styleSize: 15)
						.disableAutocorrection(true)
						.autocapitalization(.none)
						.frame(height: 25)
						.padding(.horizontal, 20)
						.padding(.vertical, 15)
						.background(.white)
						.cornerRadius(60)
						.overlay(
							RoundedRectangle(cornerRadius: 60)
								.inset(by: 0.5)
								.stroke(isOutboundProxyFocused ? Color.orangeMain500 : Color.gray200, lineWidth: 1)
						)
						.focused($isOutboundProxyFocused)
						.onChange(of: accountLoginViewModel.outboundProxy) { newValue in
							accountLoginViewModel.sipProxyUrl = newValue
						}
						.padding(.leading, 30)
						.padding(.bottom, 4)
				}
				
				// Radio: target domain
				Button(action: {
					accountLoginViewModel.outboundMode = .targetDomain
				}) {
					HStack(spacing: 10) {
						Image(systemName: accountLoginViewModel.outboundMode == .targetDomain ? "largecircle.fill.circle" : "circle")
							.resizable()
							.frame(width: 20, height: 20)
							.foregroundColor(accountLoginViewModel.outboundMode == .targetDomain ? Color.orangeMain500 : Color.grayMain2c500)
						
						Text("outbound_mode_target_domain")
							.default_text_style(styleSize: 14)
							.foregroundStyle(Color.grayMain2c700)
					}
				}
				.padding(.bottom, 15)
				

			}
			.frame(maxWidth: SharedMainViewModel.shared.maxWidth)
			.padding(.horizontal, 20)
			
			Spacer()
			
			Button(action: {
				self.accountLoginViewModel.login()
			}, label: {
				Text("assistant_account_login")
					.text_style(
						fontSize: 20,
						fontWeight: 800,
						fontColor: (accountLoginViewModel.username.isEmpty || accountLoginViewModel.passwd.isEmpty || accountLoginViewModel.domain.isEmpty) ? Color.grayMain2c600 : Color.white
					)
					.frame(height: 35)
					.frame(maxWidth: .infinity)
			})
			.padding(.horizontal, 20)
			.padding(.vertical, 10)
			.background(
				(accountLoginViewModel.username.isEmpty || accountLoginViewModel.passwd.isEmpty || accountLoginViewModel.domain.isEmpty)
				? Color.orangeMain100
				: Color.orangeMain500)
			.cornerRadius(60)
			.disabled(accountLoginViewModel.username.isEmpty || accountLoginViewModel.passwd.isEmpty || accountLoginViewModel.domain.isEmpty)
			.frame(maxWidth: SharedMainViewModel.shared.maxWidth)
			.padding(.horizontal)
			.padding(.bottom)
		}
		.frame(minHeight: geometry.size.height)
		.padding(.bottom, keyboard.currentHeight)
	}
}

#Preview {
	ThirdPartySipAccountLoginFragment(accountLoginViewModel: AccountLoginViewModel())
}

class ParticleSystem: ObservableObject {
	struct Particle {
		var x: Double
		var y: Double
		var vx: Double
		var vy: Double
		var radius: Double
	}
	
	var particles: [Particle] = []
	var lastUpdate: TimeInterval = 0
	
	func setup(size: CGSize) {
		if !particles.isEmpty { return }
		for _ in 0..<30 {
			particles.append(Particle(
				x: Double.random(in: 0...Double(size.width)),
				y: Double.random(in: 0...Double(size.height)),
				vx: Double.random(in: -15...15),
				vy: Double.random(in: -15...15),
				radius: Double.random(in: 1.5...3.0)
			))
		}
	}
	
	func update(time: TimeInterval, size: CGSize) {
		if lastUpdate == 0 {
			lastUpdate = time
			return
		}
		let dt = time - lastUpdate
		lastUpdate = time
		
		for i in 0..<particles.count {
			var p = particles[i]
			p.x += p.vx * dt
			p.y += p.vy * dt
			
			if p.x < 0 { p.x = 0; p.vx *= -1 }
			if p.x > Double(size.width) { p.x = Double(size.width); p.vx *= -1 }
			if p.y < 0 { p.y = 0; p.vy *= -1 }
			if p.y > Double(size.height) { p.y = Double(size.height); p.vy *= -1 }
			
			particles[i] = p
		}
	}
}

struct FullScreenParticlesEffect: View {
	@StateObject private var system = ParticleSystem()
	
	var body: some View {
		if #available(iOS 15.0, *) {
			TimelineView(.animation) { timeline in
				Canvas { context, size in
					system.setup(size: size)
					system.update(time: timeline.date.timeIntervalSinceReferenceDate, size: size)
					
					let maxDist: Double = 120.0
					
					// Draw connections
					for i in 0..<system.particles.count {
						for j in (i+1)..<system.particles.count {
							let p1 = system.particles[i]
							let p2 = system.particles[j]
							let dist = hypot(p1.x - p2.x, p1.y - p2.y)
							if dist < maxDist {
								var path = Path()
								path.move(to: CGPoint(x: p1.x, y: p1.y))
								path.addLine(to: CGPoint(x: p2.x, y: p2.y))
								let opacity = 1.0 - (dist / maxDist)
								context.stroke(path, with: .color(Color(red: 30/255.0, green: 136/255.0, blue: 229/255.0).opacity(opacity * 0.4)), lineWidth: 1)
							}
						}
					}
					
					// Draw particles
					for p in system.particles {
						let rect = CGRect(x: p.x - p.radius, y: p.y - p.radius, width: p.radius*2, height: p.radius*2)
						context.fill(Path(ellipseIn: rect), with: .color(Color(red: 30/255.0, green: 136/255.0, blue: 229/255.0).opacity(0.6)))
					}
				}
			}
		} else {
			EmptyView()
		}
	}
}

struct AnimatedBlueBottomBand: View {
	@State private var animate = false
	
	var body: some View {
		LinearGradient(
			gradient: Gradient(colors: [
				Color.clear,
				animate 
					? Color(red: 25/255.0, green: 110/255.0, blue: 210/255.0).opacity(0.8) 
					: Color(red: 15/255.0, green: 80/255.0, blue: 180/255.0).opacity(0.9)
			]),
			startPoint: .top,
			endPoint: .bottom
		)
		.frame(height: 180)
		.animation(
			Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true),
			value: animate
		)
		.onAppear {
			animate = true
		}
		.allowsHitTesting(false)
	}
}
