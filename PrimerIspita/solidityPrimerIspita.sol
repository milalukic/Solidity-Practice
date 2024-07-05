pragma solidity >=0.8.0;


contract PetStore {

	// struktura podataka
	struct Pet {
		uint id;
		string name;				
		uint price;
		address owner;
		bool forSale;
	}

	// cuvanje ljubimaca
	mapping (uint => Pet) idToPet;

	// upravljanje ljubimcima
	uint numOfPets = 0;
	address public storeOwner = msg.sender;

	// emitovanje dogadjaja
	event PetAdded(uint id, string name, uint price, address owner);
	event PetBought(uint id, address newOwner, uint price);
	
	//modifier
	modifier onlyStoreOwner(){
		require(msg.sender == storeOwner);
		_;
	}

	// funkcije
	function _addPet(string memory _name, uint _price) public onlyStoreOwner{
		require(bytes(_name).length > 0);
		require(_price > 0);
		
		numOfPets++;
		idToPet[numOfPets] = new Pet(numOfPets, _name, _price, storeOwner, true);
		
		emit PetAdded(_id, _name, _price, storeOwner);
	}

	// payable:
		// msg.sender - osoba koja salje novac (address)
		// msg.value - kolicina novca (wei)
	function _buyPet(uint _id) public payable{
		Pet storage pet = idToPet[_id];

		require(_id > 0 && _id <= numOfPets);
		require(msg.value == pet.price);
		require(pet.forSale == true);
		require(pet.owner != msg.sender);

		address previousOwner = pet.owner;
		pet.owner = msg.sender;
		pet.forSale = false;

		payable(previousOwner).transfer(msg.value);

		emit PetBought(_id, msg.sender, pet.price);
	}

	function _getPet(uint _id) public view returns (Pet memory){
		require(_id > 0 && _id <= numOfPets);
		return pets[_id];
	}
}
