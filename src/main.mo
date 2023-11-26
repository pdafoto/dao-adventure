import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import TrieMap "mo:base/TrieMap";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Account "account";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import List "mo:base/List";
import Http "http";
actor class DAO() = this {

	///////////////
	// LEVEL #1 //
	/////////////
	//1. Define an immutable variable name of type Text that represents the name of your DAO.
	let name : Text = "TrueDem";
	//2. Define a mutable variable manifesto of type Text that represents the manifesto of your DAO.
	var manifesto : Text = "TrueDem will offer groups, associations, and organizations a simple, secure, and effective system for conducting voting.";
	//3. Implement the getName query function, this function takes no parameters and returns the name of your DAO.
	public query func getName() : async Text {
		return name;
	};
	//4.Implement the getManifesto query function, this function takes no parameters and returns the manifesto of your DAO.
	public query func getManifesto() : async Text {
		return manifesto;
	};
	//5.Implement the setManifesto function, this function takes a newManifesto of type Text as a parameter, updates the value of manifesto and returns nothing.
	public func setManifesto(newManifesto : Text) : async () {
		manifesto := newManifesto;
		return;
	};
	//6.Define a mutable variable goals of type Buffer<Text> will store the goals of your DAO.
	let goals = Buffer.Buffer<Text>(0);
	//7.Implement the addGoal function, this function takes a goal of type Text as a parameter, adds a new goal to the goals buffer and returns nothing.
	public func addGoal(newGoal : Text) : async () {
		goals.add(newGoal);
		return;
	};
	//8.Implement the getGoals query function, this function takes no parameters and returns all the goals of your DAO in an Array.
	public query func getGoals() : async [Text] {
		return Buffer.toArray(goals);
	};

	///////////////
	// LEVEL #2 //
	/////////////
	public type Member = {
		name : Text;
		age : Nat;
	};
	public type Result<A, B> = Result.Result<A, B>;
	public type HashMap<A, B> = HashMap.HashMap<A, B>;
	//1. Define an immutable variable `members` of type `Hashmap<Principal,Member>` that will be used to store the members of your DAO.
	let members : HashMap.HashMap<Principal, Member> = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);
	//2. Implement the `addMember` function, this function takes a `member` of type `Member` as a parameter, adds a new `member` to the `members` hashmap. The function should check if the `caller` is already a member. If that's the case use the `Result` type to return an error message.
	public shared ({ caller }) func addMember(member : Member) : async Result<(), Text> {
		switch (members.get(caller)) {
			case (? member) {
				return #err("Already a member");
			};
			case (null) {
				members.put(caller, member);
				return #ok();
			};
		};
	};
	//4. Implement the `updateMember` function, this function takes a `member` of type `Member` as a parameter and updates the corresponding member. You will us the `Result` type for your return value. If the member doesn't exist, return an error message.
	public shared ({ caller }) func updateMember(member : Member) : async Result<(), Text> {
		switch (members.get(caller)) {
			case (null) {
				return #err("Member not found");
			};
			case (? _) {
				members.put(caller, member);
				return #ok();
			};
		};
	};
	//7. Implement the `removeMember` function, this function takes a `principal` of type `Principal` as a parameter and removes the corresponding member. You will us the `Result` type for your return value. If the member doesn't exist, return an error message.
	public shared ({ caller }) func removeMember() : async Result<(), Text> {
		switch (members.get(caller)) {
			case (null) {
				return #err("Member not found");
			};
			case (? member) {
				members.delete(caller);
				return #ok();
			};
		};
	};
	//3. Implement the `getMember` query function, this function takes a `principal` of type `Principal` as a parameter and returns the corresponding member. You will us the `Result` type for your return value.
	public query func getMember(principal : Principal) : async Result<Member, Text> {
		switch (members.get(principal)) {
			case (null) {
				return #err("Member not found");
			};
			case (? member) {
				return #ok(member);
			};

		};
	};
	//5. Implement the `getAllMembers` query function, this function takes no parameters and returns all the members of your DAO as an array of type `[Member]`.
	public query func getAllMembers() : async [Member] {
		return Iter.toArray(members.vals());
	};
	//6. Implement the `numberOfMembers` query function, this function takes no parameters and returns the number of members of your DAO as a `Nat`.
	public query func numberOfMembers() : async Nat {
		return members.size();
	};

	///////////////
	// LEVEL #3 //
	/////////////
	// For this level make sure to use the helpers function in Account.mo

	public type Subaccount = Blob;
	public type Account = {
		owner : Principal;
		subaccount : ?Subaccount;
	};
	//1. Define the `ledger` variable. This variable will be used to store the balance of each account. The key of the `ledger` variable is of type `Account` and the value is of type `Nat`.
	var ledger : HashMap.HashMap<Account, Nat> = HashMap.HashMap(0, Account.accountsEqual, Account.accountsHash);
	//2. Implement the `tokenName` function, this function takes no parameters and returns the name of your token as a `Text`.
	let token : Text = "Democratics";
	public query func tokenName() : async Text {
		return token;
	};
	//3. Implement the `tokenSymbol` function, this function takes no parameters and returns the symbol of your token as a `Text`.
	let tokenid : Text = "DMC";
	public query func tokenSymbol() : async Text {
		return tokenid;
	};
	//4. Implement the `mint` function. This function takes a `Principal` and a `Nat` as arguments. It adds the `Nat` to the balance of the default account of the given `Principal` and returns nothing.
	public func mint(to : Principal, amount : Nat) : async () {
		let account : Account.Account = {
			owner = to;
			subaccount = null;
		};
		ledger.put(account, amount);
	};
	//5. Implement the `transfer` function. This function takes an `Account` object for the sender (`from`), an `Account` object for the recipient (`to`), and a `Nat` value for the amount to be transferred. It transfers the specified amou
	public shared ({ caller }) func transfer(from : Account, to : Account, amount : Nat) : async Result<(), Text> {
		let origin = ledger.get(from);
		switch (origin) {
			case (null) {
				return #err("Sender has no account.");
			};
			case (?origin) {
				if (origin < amount) {
					return #err ("Insuficent funds in your account.");
				}
				else {
					let destination = ledger.get(to);
					switch (destination) {
						case (null) {
							ledger.put(to, amount);
						};
						case (?destination) {
							ledger.put(to, destination + amount);
						};
					};
					ledger.put(from, origin - amount);
					return #ok();
				};
			};
		};
	};
	//6. Implement the `balanceOf` query function. This function takes an `Account` object as an argument and returns the balance of the given account as a `Nat`. It returns 0 if the account does not exist in the `ledger` variable.
	public query func balanceOf(account : Account) : async Nat {
		let balance = ledger.get(account);
		switch (balance){
			case (null){
				return 0;
			};
			case (?balance){
				return balance;
			};
		};
	};
	//7. Implement the `totalSupply` query function. This function takes no parameters and returns the total supply of your token as a `Nat`.
	public query func totalSupply() : async Nat {
		var total : Nat = 0;
		for (balance in ledger.vals()) {
			total += balance;
		};
		return total;
	};

	///////////////
	// LEVEL #4 //
	/////////////
	// For this level you need to make use of the code implemented in Level 3

	public type Status = {
		#Open;
		#Accepted;
		#Rejected;
	};

	public type Proposal = {
		id : Nat;
		status : Status;
		manifest : Text;
		votes : Int;
		voters : [Principal];
	};
	//1. Define a mutable variable `nextProposalId` of type `Nat` that will keep track of the next proposal's identifier. Every time a proposal is created, this variable will be incremented by `1`.
	var nextProposalId : Nat = 1;
	//2. Define an immutable variable called `proposals` of type `TrieMap<Nat, Proposal>`. In this datastructure, the keys are of type `Nat` and represent the unique identifier of each proposal. The values are of type `Proposal` and represent the proposal itself.
	let proposals : TrieMap.TrieMap<Nat, Proposal> = TrieMap.TrieMap(Nat.equal, Hash.hash);
	public type CreateProposalOk = Nat;

	public type CreateProposalErr = {
		#NotDAOMember;
		#NotEnoughTokens;
	};

	public type createProposalResult = Result<CreateProposalOk, CreateProposalErr>;

	public type VoteOk = {
		#ProposalAccepted;
		#ProposalRefused;
		#ProposalOpen;
	};

	public type VoteErr = {
		#ProposalNotFound;
		#AlreadyVoted;
		#ProposalEnded;
	};

	public type voteResult = Result<VoteOk, VoteErr>;
	//3. Implement the `createProposal` function. This function takes a `manifest` of type `Text` as a parameter and returns a `CreateProposalResult` type. This function will be used to create a new proposal. The function should check if the caller is a member of the DAO and if they have enough tokens to create a proposal. If that's the case, the function should create a new proposal and return the `ProposalCreated` case of the `CreateProposalOk` type with the value of the proposal's `id` field. Otherwise it should return the corresponding error.
	public shared ({ caller }) func createProposal(manifest : Text) : async createProposalResult {
		switch (members.get(caller)) {
			case (null) {
				return #err(#NotDAOMember);
			};
			case (?member) {
				let account : Account.Account = {
					owner = caller;
					subaccount = null;
				};
				let balance = ledger.get(account);
				switch (balance) {
					case (null) {
						return #err(#NotEnoughTokens);
					};
					case (? balance) {
						if (balance < 1) {
							return #err(#NotEnoughTokens);
						}
						else {
							let proposal : Proposal = {
								id = nextProposalId;
								status = #Open;
								manifest = manifest;
								votes = 0;
								voters = [];
							};
							proposals.put(nextProposalId, proposal);
							nextProposalId += 1;
							return #ok(nextProposalId - 1);
						};
					};
				};
			};
		};
	};
	//4. Implement the `getProposal` query function. This function takes a `Nat` as an argument and returns the proposal with the corresponding identifier as a `?Proposal`. If no proposal exists with the given identifier, it should return `null`.
	public query func getProposal(id : Nat) : async ?Proposal {
		proposals.get(id);
	};
	//5. Implement the `vote` function that takes a `Nat` and a `Bool` as arguments and returns a `VoteResult` type. This function will be used to vote on a proposal. The `Nat` represents the identifier of the proposal and the `Bool` represents the vote. If the `Bool` is `true`, the vote is an `Up` vote. If the `Bool` is `false`, the vote is a `Down` vote. The function should perfom necessary checks before accepting a vote.
	public shared ({ caller }) func vote(id : Nat, vote : Bool) : async voteResult {
		switch (proposals.get(id)) {
			case (null) {
				return #err(#ProposalNotFound);
			};
			case (? proposal) {
				let hasVoted = switch(Array.find<Principal>(proposal.voters, func(x) {x == caller})) {
					case (null) { false };
					case (_) { true };
				};
				if hasVoted return #err(#AlreadyVoted);
				if (proposal.status != #Open) return #err(#ProposalEnded);
				let power = await balanceOf({
					owner = caller;
					subaccount = null;
				});
				var votes = proposal.votes;
				if (vote) {
					votes += power;
				}
				else votes -= power;
				let v = Array.append<Principal>(proposal.voters, [caller]);
				if (votes >= 1) {
					let p = {
						id = nextProposalId;
						status = #Accepted;
						manifest = proposal.manifest;
						votes = votes;
						voters = v;
					};
					proposals.put(proposal.id, p);
					return #ok(#ProposalAccepted);
				};
				if (votes <= -1) {
					let p = {
						id = proposal.id;
						status = #Rejected;
						manifest = proposal.manifest;
						votes = votes;
						voters = v;
					};
					proposals.put(proposal.id, p);
					return #ok(#ProposalRefused);
				};
				let p = {
					id = proposal.id;
					status = #Open;
					manifest = proposal.manifest;
					votes = votes;
					voters = v;
				};
				proposals.put(proposal.id, p);
				return #ok(#ProposalOpen);
			};
		};
	};

	///////////////
	// LEVEL #5 //
	/////////////
	//1. Select a logo for the DAO. You will need to find a logo that is available as an SVG file. You can use a website like [FlatIcon](https://www.flaticon.com/fr/).
	//2. Define an immutable variable called `logo` of type `Text` and set it to the value of the SVG file.
	let logo : Text = "<svg id='Layer_1' height='512' viewBox='0 0 24 24' width='512' xmlns='http://www.w3.org/2000/svg' data-name='Layer 1'><path d='m17 0a1 1 0 0 0 -1 1c0 2.949-2.583 4-5 4h-7a4 4 0 0 0 -4 4v2a3.979 3.979 0 0 0 1.514 3.109l3.572 7.972a3.233 3.233 0 0 0 2.953 1.919 2.982 2.982 0 0 0 2.72-4.2l-2.2-4.8h2.441c2.417 0 5 1.051 5 4a1 1 0 0 0 2 0v-18a1 1 0 0 0 -1-1zm-8.063 20.619a.983.983 0 0 1 -.898 1.381 1.232 1.232 0 0 1 -1.126-.734l-2.808-6.266h2.254zm7.063-6.019a7.723 7.723 0 0 0 -5-1.6h-7a2 2 0 0 1 -2-2v-2a2 2 0 0 1 2-2h7a7.723 7.723 0 0 0 5-1.595zm7.9.852a1 1 0 0 1 -1.342.448l-2-1a1 1 0 0 1 .894-1.79l2 1a1 1 0 0 1 .448 1.337zm-3.79-9a1 1 0 0 1 .448-1.342l2-1a1 1 0 1 1 .894 1.79l-2 1a1 1 0 0 1 -1.342-.448zm-.11 3.548a1 1 0 0 1 1-1h2a1 1 0 0 1 0 2h-2a1 1 0 0 1 -1-1z'/></svg>";

	func _getWebpage() : Text {
		var webpage = "<style>" #
		"body { text-align: center; font-family: Arial, sans-serif; background-color: #f0f8ff; color: #333; }" #
		"h1 { font-size: 3em; margin-bottom: 10px; }" #
		"hr { margin-top: 20px; margin-bottom: 20px; }" #
		"em { font-style: italic; display: block; margin-bottom: 20px; }" #
		"ul { list-style-type: none; padding: 0; }" #
		"li { margin: 10px 0; }" #
		"li:before { content: '👉 '; }" #
		"svg { max-width: 150px; height: auto; display: block; margin: 20px auto; }" #
		"h2 { text-decoration: underline; }" #
		"</style>";

		webpage := webpage # "<div><h1>" # name # "</h1></div>";
		webpage := webpage # "<em>" # manifesto # "</em>";
		webpage := webpage # "<div>" # logo # "</div>";
		webpage := webpage # "<hr>";
		webpage := webpage # "<h2>Our goals:</h2>";
		webpage := webpage # "<ul>";
		for (goal in goals.vals()) {
			webpage := webpage # "<li>" # goal # "</li>";
		};
		webpage := webpage # "</ul>";
		return webpage;
	};

	public type DAOInfo = {
		name : Text;
		manifesto : Text;
		goals : [Text];
		member : [Text];
		logo : Text;
		numberOfMembers : Nat;
	};
	public type HttpRequest = Http.Request;
	public type HttpResponse = Http.Response;
	//4. Implement the `http_request` query function. This function takes a `request` of type `HttpRequest` as a parameter and returns a `HttpResponse` object. This function will be used to serve the webpage of your DAO.
	public func http_request(request : HttpRequest) : async HttpResponse {
		let page = _getWebpage();
		return ({
			status_code = 200 : Nat16;
			headers = [("Content-Type", "text/html; charset=UTF-8")];
			body = Text.encodeUtf8(page);
			streaming_strategy = null;
		});
	};
	//3. Implement the function `getStats`. This function takes no parameters and returns a `DAOInfo` object that contains updated information about the DAO.
	public query func getStats() : async DAOInfo {
		let memberNames = Iter.map(members.vals(), func (member : Member) : Text { member.name });
		return ({
			name = name;
			manifesto = manifesto;
			goals = Buffer.toArray(goals);
			member = Iter.toArray(memberNames);
			logo = logo;
			numberOfMembers = members.size();
		});
	};

	//////////////////
	// DO NOT REMOVE /
	/////////////////

	public shared ({ caller }) func whoami() : async Principal {
		return caller;
	};
};
