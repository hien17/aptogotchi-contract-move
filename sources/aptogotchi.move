module aptogotchi::main {
    use aptos_framework::event;
    use aptos_framework::object;
    use aptos_framework::timestamp;
    use aptos_framework::object::ExtendRef;
    use aptos_std::string_utils::{to_string};
    use aptos_token_objects::collection;
    use aptos_token_objects::token;
    use std::error;
    use std::option;
    use std::signer::address_of;
    use std::string::{Self, String};

    /// aptogotchi not available
    const ENOT_AVAILABLE: u64 = 1;
    /// name length exceeded limit
    const ENAME_LIMIT: u64 = 2;
    /// user already has aptogotchi
    const EUSER_ALREADY_HAS_APTOGOTCHI: u64 = 3;
    /// invalid body value
    const EBODY_VALUE_INVALID: u64 = 4;
    /// invalid ear value
    const EEAR_VALUE_INVALID: u64 = 5;
    /// invalid face va lue
    const EFACE_VALUE_INVALID: u64 = 6;

    /// maximum health points: 5 hearts * 2 HP/heart = 10 HP
    const ENERGY_UPPER_BOUND: u64 = 10;
    const NAME_UPPER_BOUND: u64 = 40;

    struct AptogotchiParts has copy, drop, key, store {
        body: u8,
        ear: u8,
        face: u8
    }

    struct Aptogotchi has key {
        name: String,
        birthday: u64,
        energy_points: u64,
        parts: AptogotchiParts,
        mutator_ref: token::MutatorRef,
        burn_ref: token::BurnRef,
    }

    #[event]
    struct MintAptogotchiEvent has drop, store {
        token_name: String,
        aptogotchi_name: String,
        parts: AptogotchiParts,
    }

    // We need a contract signer as the creator of the aptogotchi collection and aptogotchi token
    // Otherwise we need admin to sign whenever a new aptogotchi token is minted which is inconvenient
    struct ObjectController has key {
        // This is the extend_ref of the app object, not the extend_ref of collection object or token object
        // app object is the creator and owner of aptogotchi collection object
        // app object is also the creator of all aptogotchi token (NFT) objects
        // but owner of each token object is aptogotchi owner (i.e user who mints )
        app_extend_ref: ExtendRef,
    }

    const APP_OBJECT_SEED: vector<u8> = b"APTOGOTCHI";
    const APTOGOTCHI_COLLECTION_NAME: vector<u8> = b"Aptogotchi Collection";
    const APTOGOTCHI_COLLECTION_DESCRIPTION: vector<u8> = b"Aptogotchi Collection Description";
    const APTOGOTCHI_COLLECTION_URI: vector<u8> = b"https://otjbxblyfunmfblzdegw.supabase.co/storage/v1/object/public/aptogotchi/aptogotchi.png";
    // Body value range is [0, 4] inclusive
    const BODY_MAX_VALUE: u8 = 4;
    // Ear value range is [0, 5] inclusive
    const EAR_MAX_VALUE: u8 = 6;
    // Face value range is [0, 3] inclusive
    const FACE_MAX_VALUE: u8 = 3;

    // This function is only called once when the module is published for the first time.
    fun init_module(account: &signer) {
        let constructor_ref = object::create_named_object(
            account,
            APP_OBJECT_SEED,
        );
        let extend_ref = object::generate_extend_ref(&constructor_ref);
        let app_signer = &object::generate_signer(&constructor_ref);

        move_to(app_signer, ObjectController {
            app_extend_ref: extend_ref,
        });

        create_aptogotchi_collection(app_signer);
    }


    fun get_app_signer_addr(): address {
        object::create_object_address(&@aptogotchi, APP_OBJECT_SEED)
    }

    fun get_app_signer(): signer acquires ObjectController {
        object::generate_signer_for_extending(&borrow_global<ObjectController>(get_app_signer_addr()).app_extend_ref)
    }

    // Create the collection that hold all Aptogotchis
    fun create_aptogotchi_collection(creator: &signer) {
        let description = string::utf8(APTOGOTCHI_COLLECTION_DESCRIPTION);
        let name = string::utf8(APTOGOTCHI_COLLECTION_NAME);
        let uri = string::utf8(APTOGOTCHI_COLLECTION_URI);

        collection::create_unlimited_collection(
            creator,
            description,
            name,
            option:: none(),
            uri,
        );
    }

    // Create an Aptogotchi token object
    public entry fun create_aptogotchi(
        user: &signer,
        name: String,
        body: u8,
        ear: u8,
        face: u8
    ) acquires ObjectController {
        assert!(string::length(&name) <= NAME_UPPER_BOUND, error::invalid_argument(ENAME_LIMIT));
        assert!(
            body >= 0 && body <=EAR_MAX_VALUE,
            error::invalid_argument(EFACE_VALUE_INVALID)
        );

        let uri = string::utf8(APTOGOTCHI_COLLECTION_URI);
        let description = string::utf8(APTOGOTCHI_COLLECTION_DESCRIPTION);
        let user_addr = address_of(user);
        let token_name = to_string(&user_addr);
        let parts = AptogotchiParts {
            body,
            ear,
            face,
        };
        assert!(!has_aptogotchi(user_addr), error::already_exists(EUSER_ALREADY_HAS_APTOGOTCHI));

        let constructor_ref = token::create_named_token(
            &get_app_signer(),
            string::utf8(APTOGOTCHI_COLLECTION_NAME),
            description,
            token_name,
            option::none(),
            uri,
        );

        let token_signer = object::generate_signer(&constructor_ref);
        let mutator_ref = token::generate_mutator_ref(&constructor_ref);
        let burn_ref = token::generate_burn_ref(&constructor_ref);
        let transfer_ref = object::generate_transfer_ref(&constructor_ref);

        // initialize/ set default Aptogotchi struct values
        let gotchi = Aptogotchi {
            name,
            birthday: timestamp::now_seconds(),
            energy_points: ENERGY_UPPER_BOUND,
            parts,
            mutator_ref,
            burn_ref,
        };

        move_to(&token_signer, gotchi);

        // Emit event for minting Aptogotchi token
        event::emit<MintAptogotchiEvent>(
            MintAptogotchiEvent {
                token_name,
                aptogotchi_name: name,
                parts
            },
        );

        object::transfer_with_ref(object::generate_linear_transfer_ref(&transfer_ref), address_of(user));
    }

    // Sets aptogotchi's name
    public entry fun set_name(owner: &signer, name: String) acquires Aptogotchi {
        let owner_addr = address_of(owner);
        assert!(has_aptogotchi(owner_addr), error::unavailable(ENOT_AVAILABLE));

        assert!(string::length(&name) <= NAME_UPPER_BOUND, error::invalid_argument(ENAME_LIMIT));

        let token_address = get_aptogotchi_address(owner_addr);
        let gotchi = borrow_global_mut<Aptogotchi>(token_address);
        gotchi.name = name;
    }

    // Feeds aptogotchi to increase its energy points
    public entry fun feed(owner: &signer, points: u64) acquires Aptogotchi {
        let owner_addr = address_of(owner);
        assert!(has_aptogotchi(owner_addr), error::unavailable(ENOT_AVAILABLE));

        let token_address = get_aptogotchi_address(owner_addr);
        let gotchi = borrow_global_mut<Aptogotchi>(token_address);

        gotchi.energy_points = if (gotchi.energy_points + points > ENERGY_UPPER_BOUND) {
            ENERGY_UPPER_BOUND
        } else {
            gotchi.energy_points + points
        };
    }

    // Play with aptogotchi to consume its enery points
    public entry fun play(owner: &signer, points: u64) acquires Aptogotchi {
        let owner_addr = address_of(owner);
        assert!(has_aptogotchi(owner_addr), error::unavailable(ENOT_AVAILABLE));

        let token_address = get_aptogotchi_address(owner_addr);
        let gotchi = borrow_global_mut<Aptogotchi>(token_address);

        gotchi.energy_points = if (gotchi.energy_points < points) {
            0
        } else {
            gotchi.energy_points - points
        };
    }

    // Sets Aptogotchi's parts
    public entry fun set_parts(owner: &signer, body: u8, ear: u8, face: u8) acquires Aptogotchi {
        let owner_addr = address_of(owner);
        assert!(has_aptogotchi(owner_addr), error::unavailable(ENOT_AVAILABLE));

        let token_address = get_aptogotchi_address(owner_addr);
        let gotchi = borrow_global_mut<Aptogotchi>(token_address);

        gotchi.parts.body = body;
        gotchi.parts.ear = ear;
        gotchi.parts.face = face;
    }

    // Returns true if this address owns an Aptogotchi
    #[view]
    public fun has_aptogotchi(owner_addr: address): bool {
        let token_address = get_aptogotchi_address(owner_addr);

        exists<Aptogotchi>(token_address)
    }

    // Get reference to Aptogotchi token object (CAN'T modify the reference)
    #[view]
    public fun get_aptogotchi_address(
        creator_addr: address
    ): address {
        let collection_name = string::utf8(APTOGOTCHI_COLLECTION_NAME);
        // Token name is address of user who create aptogotchi
        let token_name = to_string(&creator_addr);
        // Creator of collection is app signer
        let creator_addr = get_app_signer_addr();
        let token_address = token::create_token_address(
            &creator_addr,
            &collection_name,
            &token_name
        );

        token_address
    }

    // Get collection address (also known as collection ID) of aptogotchi collection
    // Collection itself is an object, that's why it has an address
    #[view]
    public fun get_aptogotchi_collection_address(): address {
        let collection_name = string::utf8(APTOGOTCHI_COLLECTION_NAME);
        let creator_addr = get_app_signer_addr();
        collection::create_collection_address(&creator_addr, &collection_name)
    }

    // Returns all fields of this Aptogotchi (if found)
    #[view]
    public fun get_aptogotchi(
        owner_addr: address
    ): (String, u64, u64, AptogotchiParts) acquires Aptogotchi {
        // If thif address doesn't have an aptogotchi, throw error
        assert!(has_aptogotchi(owner_addr), error::unavailable(ENOT_AVAILABLE));

        let token_address = get_aptogotchi_address(owner_addr);
        let gotchi = borrow_global<Aptogotchi>(token_address);

        // view function can only return primitive types
        (gotchi.name, gotchi.birthday, gotchi.energy_points, gotchi.parts)
    }

    // === TESTS ===
    // Setup testing environment
    #[test_only]
    use aptos_framework::account::create_account_for_test;
    #[test_only]
    use std::string::utf8;

    #[test_only]
    fun setup_test(aptos: &signer, account: &signer, user: &signer) {
        // create a fake account (only for testing purposes)
        create_account_for_test(address_of(user));
        create_account_for_test(address_of(account));

        timestamp::set_time_has_started_for_testing(aptos);
        init_module(account);
    }

    // Test creating an Aptogotchi
    #[test(aptos = @0x1, account = @aptogotchi, user = @0x123)]
    fun test_create_aptogotchi(
        aptos: &signer,
        account: &signer,
        user: &signer
    ) acquires ObjectController {
        setup_test(aptos, account, user);

        create_aptogotchi(user, utf8(b"test"), 1, 1, 1);

        let has_aptogotchi = has_aptogotchi(address_of(user));
        assert!(has_aptogotchi, 1);
    }

    // Test getting an Aptogotchi, when user has not minted
    #[test(aptos = @0x1, account = @aptogotchi, user = @0x123)]
    #[expected_failure(abort_code = 851969, location = aptogotchi::main)]
    fun test_create_aptogotchi_without_creation(
        aptos: &signer,
        account: &signer,
        user: &signer
    ) acquires Aptogotchi {
        setup_test(aptos, account, user);

        // get aptogotchi without creating it
        get_aptogotchi(address_of(user));
    }

    // Test feeding and playing with the Aptogotchi
    #[test(aptos = @0x1, account = @aptogotchi, user = @123)]
    fun test_feed_and_play(
        aptos: &signer,
        account: &signer,
        user: &signer,
    ) acquires ObjectController, Aptogotchi {
        setup_test(aptos, account, user);
        
        create_aptogotchi(user, utf8(b"test"), 1, 1, 1);

        let user_addr = address_of(user);

        let (_, _, energy_point_1, _) = get_aptogotchi(user_addr); 
        assert!(energy_point_1 == ENERGY_UPPER_BOUND, 1);

        play(user, 5);
        let (_, _, energy_point_2, _) = get_aptogotchi(user_addr);
        assert!(energy_point_2 == ENERGY_UPPER_BOUND - 5, 2);

        feed(user, 3);
        let (_, _, energy_point_3, _) = get_aptogotchi(user_addr); 
        assert!(energy_point_3 == ENERGY_UPPER_BOUND - 2, 1);
    }

    // Test minting an Aptogotchi twice
    #[test(aptos = @0x1, account = @aptogotchi, user = @0x123)]
    #[expected_failure(abort_code = 524291, location = aptogotchi::main)]
    fun test_create_aptogotchi_twice(
        aptos: &signer,
        account: &signer,
        user: &signer,
    ) acquires ObjectController {
        setup_test(aptos, account, user);

        create_aptogotchi(user, utf8(b"test"), 1, 1, 1);
        create_aptogotchi(user, utf8(b"test"), 1, 1, 1);
    }

    // Test setting new name for an aptogotchi
    #[test(aptos = @0x1, account = @aptogotchi, user = @0x123)]
    fun test_set_name(
        aptos: &signer,
        account: &signer,
        user: &signer,
    ) acquires ObjectController, Aptogotchi {
        setup_test(aptos, account, user);

        create_aptogotchi(user, utf8(b"test"), 1, 1, 1);

        let newName = utf8(b"new name");
        set_name(user, newName);

        let user_addr = address_of(user);
        let (name, _, _, _) = get_aptogotchi(user_addr);
        assert!(name == newName, 1);
    }

    // Test setting new parts for an aptogotchi
    #[test(aptos = @0x1, account = @aptogotchi, user = @0x123)]
    fun test_set_parts(
        aptos: &signer,
        account: &signer,
        user: &signer,
    ) acquires ObjectController, Aptogotchi {
        setup_test(aptos, account, user);

        create_aptogotchi(user, utf8(b"test"), 1, 1, 1);

        let newBody = 2;
        let newEar = 3;
        let newFace = 4;
        set_parts(user, newBody, newEar, newFace);

        let user_addr = address_of(user);
        let (_, _, _, parts) = get_aptogotchi(user_addr);
        assert!(parts.body == newBody, 1);
        assert!(parts.ear == newEar, 1);
        assert!(parts.face == newFace, 1);
    }
}