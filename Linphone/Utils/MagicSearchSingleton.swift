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

import linphonesw
import Combine
import SwiftUI

final class MagicSearchSingleton: ObservableObject {
	
	static let shared = MagicSearchSingleton()
	private var coreContext = CoreContext.shared
	private var contactsManager = ContactsManager.shared
	
	private var magicSearch: MagicSearch?
	
	var currentFilter: String = ""
	var previousFilter: String?
	
	var needUpdateLastSearchContacts = false
	
	private var limitSearchToLinphoneAccounts = true
	
	@Published var allContact = true
	
	var linphoneDomain = true
	var domainDefaultAccount = ""
	
	var searchDelegate: MagicSearchDelegate?
    
    private var contactLoadedDebounceWorkItem: DispatchWorkItem?
    
    let nativeAddressBookFriendList = "Native address-book"
    let linphoneAddressBookFriendList = "Linphone address-book"
    let tempRemoteAddressBookFriendList = "TempRemoteDirectoryContacts address-book"
	
	@Published var importedContactOnly: Bool = false
	
	@Published var isLoading = false
	
	func destroyMagicSearch() {
		magicSearch = nil
	}
	
	private init() {
		allContact = AppServices.corePreferences.contactsFilter == "" || AppServices.corePreferences.contactsFilter == "IMPORTED"
		importedContactOnly = AppServices.corePreferences.contactsFilter == "IMPORTED"
		
		coreContext.doOnCoreQueue { core in
			self.linphoneDomain = AppServices.corePreferences.defaultDomain == core.defaultAccount?.params?.domain
			if self.importedContactOnly || AppServices.corePreferences.contactsFilter == "" {
				self.domainDefaultAccount = ""
			} else {
				self.domainDefaultAccount = AppServices.corePreferences.contactsFilter
			}
			
			self.magicSearch = try? core.createMagicSearch()
			
			guard let magicSearch = self.magicSearch else {
				return
			}
			
			magicSearch.limitedSearch = false
			
			self.searchDelegate = MagicSearchDelegateStub(onSearchResultsReceived: { (magicSearch: MagicSearch) in
				print("[MagicSearchSingleton] [onSearchResultsReceived] Received search results")
				self.needUpdateLastSearchContacts = true
				
				var lastSearchFriend: [SearchResult] = []
				var lastSearchSuggestions: [SearchResult] = []
				
				magicSearch.lastSearch.forEach { searchResult in
					if let friend = searchResult.friend {
						let isDuplicate = lastSearchFriend.contains(where: { $0.friend === friend })
						if !isDuplicate {
							lastSearchFriend.append(searchResult)
						}
					} else {
						lastSearchSuggestions.append(searchResult)
					}
				}
				
				lastSearchSuggestions.sort(by: {
					($0.address?.asStringUriOnly() ?? "") < ($1.address?.asStringUriOnly() ?? "")
				})
				
				if let defaultAccount = core.defaultAccount, let contactAddress = defaultAccount.params?.identityAddress {
					lastSearchSuggestions.removeAll {
						$0.address?.weakEqual(address2: contactAddress) ?? false
					}
				}
				
				let sortedLastSearch = lastSearchFriend.sorted {
					let name1 = $0.friend?.name?.lowercased()
						.folding(options: .diacriticInsensitive, locale: .current) ?? ""
					let name2 = $1.friend?.name?.lowercased()
						.folding(options: .diacriticInsensitive, locale: .current) ?? ""
					return name1 < name2
				}
				
				var addedAvatarListModel: [ContactAvatarModel] = []
				sortedLastSearch.forEach { searchResult in
					if let friend = searchResult.friend {
						let withPresence = !searchResult.hasSourceFlag(source: .LdapServers)
						let contactModel = ContactAvatarModel(
							friend: friend,
							name: friend.name ?? "",
							address: searchResult.address?.clone()?.asStringUriOnly() ?? "",
							withPresence: withPresence
						)
						
						if self.importedContactOnly {
							// Filter by note containing [CSV] or [Server]
							let note = friend.organization ?? ""
							if note.contains("[CSV]") || note.contains("[Server]") {
								addedAvatarListModel.append(contactModel)
							}
						} else {
							addedAvatarListModel.append(contactModel)
						}
					}
				}
				
				self.contactsManager.avatarListModel.forEach { contactAvatarModel in
					contactAvatarModel.removeFriendDelegate()
				}
                
                self.updateContacts(sortedLastSearch: sortedLastSearch, lastSearchSuggestions: lastSearchSuggestions, addedAvatarListModel: addedAvatarListModel)
			})
			
			magicSearch.addDelegate(delegate: self.searchDelegate!)
		}
	}
	
	func changeAllContact(allContactBool: Bool, isImportedOnly: Bool = false) {
		allContact = allContactBool
		importedContactOnly = isImportedOnly
		if isImportedOnly {
			domainDefaultAccount = ""
			AppServices.corePreferences.contactsFilter = "IMPORTED"
		} else {
			domainDefaultAccount = allContactBool ? "" : (linphoneDomain ? AppServices.corePreferences.defaultDomain : "*")
			AppServices.corePreferences.contactsFilter = domainDefaultAccount
		}
	}
    
    func updateContacts(
        sortedLastSearch: [SearchResult],
        lastSearchSuggestions: [SearchResult],
        addedAvatarListModel: [ContactAvatarModel]
    ) {
        DispatchQueue.main.async {			
			if SharedMainViewModel.shared.displayedFriend != nil {
				if let avatarModel = addedAvatarListModel.first(where: { $0.address == SharedMainViewModel.shared.displayedFriend?.address }) {
					SharedMainViewModel.shared.displayedFriend = avatarModel
				}
			}
			
            self.contactsManager.lastSearch = sortedLastSearch
            self.contactsManager.lastSearchSuggestions = lastSearchSuggestions
            
            self.contactsManager.avatarListModel.removeAll()
            self.contactsManager.avatarListModel += addedAvatarListModel

            // Cancel previous debounce task
            self.contactLoadedDebounceWorkItem?.cancel()

            // Schedule new debounce task
            let workItem = DispatchWorkItem {
                NotificationCenter.default.post(name: NSNotification.Name("ContactLoaded"), object: nil)
            }
			
			self.isLoading = false

            self.contactLoadedDebounceWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        }
    }
	
	func searchForContacts() {
		coreContext.doOnCoreQueue { _ in
			DispatchQueue.main.async {
				self.isLoading = true
			}
			
			var needResetCache = false
			
			if let oldFilter = self.previousFilter {
				if oldFilter.count > self.currentFilter.count || oldFilter != self.currentFilter {
					needResetCache = true
				}
			}
			
			self.previousFilter = self.currentFilter
			
			guard let magicSearch = self.magicSearch else {
				return
			}
			
			if needResetCache {
				magicSearch.resetSearchCache()
			}
			
			magicSearch.getContactsListAsync(
				filter: self.currentFilter,
				domain: self.allContact ? "" : self.domainDefaultAccount,
				sourceFlags: MagicSearch.Source.All.rawValue, //MagicSearch.Source.Friends.rawValue | MagicSearch.Source.LdapServers.rawValue | MagicSearch.Source.RemoteCardDAV.rawValue,
				aggregation: MagicSearch.Aggregation.Friend
			)
		}
	}
}
