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
			
			Text("assistant_login_third_party_sip_account_subtitle")
				.default_text_style(styleSize: 14)
				.foregroundStyle(Color.grayMain2c500)
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
					.default_text_style_white_600(styleSize: 20)
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
			

			LoginBackgroundEffect()
		}
		.frame(minHeight: geometry.size.height)
		.padding(.bottom, keyboard.currentHeight)
	}
}

#Preview {
	ThirdPartySipAccountLoginFragment(accountLoginViewModel: AccountLoginViewModel())
}

struct LoginBackgroundEffect: View {
	@State private var animate = false
	
	var body: some View {
		ZStack {
			// Subtle gradient
			LinearGradient(
				gradient: Gradient(colors: [Color.orangeMain500.opacity(0.15), Color.clear]),
				startPoint: .bottom,
				endPoint: .top
			)
			.frame(height: 150)
			
			// Floating Tech Particles
			GeometryReader { geometry in
				ZStack {
					ForEach(0..<6, id: \.self) { i in
						Circle()
							.fill(Color.orangeMain500.opacity(Double.random(in: 0.1...0.3)))
							.frame(width: CGFloat.random(in: 30...80))
							.blur(radius: 8)
							.offset(
								x: animate ? CGFloat.random(in: -geometry.size.width/2...geometry.size.width/2) : CGFloat.random(in: -geometry.size.width/2...geometry.size.width/2),
								y: animate ? CGFloat.random(in: -50...50) : CGFloat.random(in: -20...80)
							)
							.animation(
								Animation.easeInOut(duration: Double.random(in: 4...8))
									.repeatForever(autoreverses: true)
									.delay(Double.random(in: 0...2)),
								value: animate
							)
					}
				}
				.frame(width: geometry.size.width, height: geometry.size.height)
			}
		}
		.frame(height: 150)
		.allowsHitTesting(false)
		.onAppear {
			animate = true
		}
	}
}
