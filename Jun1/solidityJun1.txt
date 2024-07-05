pragma solidity ^0.8.0;

contract Auctions {

	// a) Definisanje strukture
	struct AuctionItem {
		uint id;
		string name;
		uint minBid;
		uint maxBid;
		address highestBidder;
		// dodatna promenljiva, da bismo znali kada je aukcija zavrsena
		bool done;
	}

	// b) niz predmeta items, id proizvoda je redni broj u nizu
	AuctionItem[] items;
	uint counter = 0;

	address owner;
	// U konstruktoru se ugovara adresa owner vlasnika
	constructor() {
		owner = msg.sender;
	}

	// samo vlasnik ugovora moze da doda proizvod i zavrsi aukciju
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	} 	

	// g) event HighestBidIncreased
	event HighestBidIncreased(uint id, address highestBidder, uint amount);

	// c) AddItem, vlasnik dodaje proizvod na aukciju
	function addItem(string _name, uint _minBid) public onlyOwner {
		
		require(bytes(_name).length > 0);
		require(_minBid > 0);	
	
		items.push(AuctionItem {
			id: counter;
			name: _name;
			minBid: _minBid;
			maxBid: 0;
			highestBidder: address(0);
			done: false;
		});

		counter++;
	}

	// d) endAuction, vlasnik zavrsava aukciju i na njegov racun se prebacuje iznos najbolje ponude
	function endAuction(uint _id) public onlyOwner{
		require(_id < counter && _id >= 0);

		AuctionItem storage item = items[_id];
		require(!item.done);

		item.done = true;

		if (item.maxBid != 0) {
			payable(owner).transfer(item.maxBid);
		}	
	}

	// e) preslikavanje pendingReturns, svakoj adresi se vraca iznos kada im se ponude poniste (funkcijom withdraw)


	mapping (address => uint) public pendingReturns;

	// f) bid, nova ponuda za predmet, saljemo ponudu visu od minimalne i trenutno najvise za predmet. Ako postoji
	// prethodna ponuda registruje se da iznos treba da se vrati prethodnom ponudjacu

	function bid(uint _id) public payable {
		require(_id >= 0 && _id < counter);
		AuctionItem storage item = items[_id];
		require(msg.value > item.minBid && msg.value > item.maxBid);

		if(item.maxBid != 0){
			pendingReturns[item.highestBidder] += maxBid;
			item.maxBid = msg.value;
			item.highestBidder = msg.sender;
		}
		
		emit HighestBidIncreased(_id, msg.sender, msg.value);	
	}

	// h) withdraw funkcija - svakom ponudjacu omogucuje da povuce sve neaktuelne ponude, vraca podatak
	// da li je uspesno vracanje novca

	function withdraw() returns (bool) {
		uint amount = pendingReturns[msg.sender];
		if (amount > 0) {
			pendingReturns[msg.sender] = 0;

			if(!payable(msg.sender).send(amount)){
				pendingReturns[msg.sender] = amount;
				return false;
			}
		}
		return true;
	}

}