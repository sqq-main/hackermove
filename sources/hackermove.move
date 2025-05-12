module hackermove::hackermove {

    use std::signer;
    use std::string;
    use std::string::String;
    use std::vector;
    use aptos_std::table::{Table, new};

    use hackermove::utils::date_formatter;

    // Errors
    const E_USER_ALREADY_REGISTERED:u64 = 1330;

    struct Certification has store, drop, copy {
        title: String,
        issuer: String,
        expiration_date: String
    }

    struct Achievement has store, drop, copy {
        title: String,
        award: String,
        date: String
    }

    struct Player has key, store {
        name: String,
        username: String,
        bio: String,
        links: vector<String>,
        skills: vector<String>,
        certifications: vector<Certification>,
        achievements: vector<Achievement>
    }

    struct PlayersRegistry has key {
        players: Table<String, address>,
        keys: vector<String>,
        count: u64
    }

    fun init_module(hackermove: &signer) {
        let players_registry = PlayersRegistry {
            players: new<String, address>(),
            keys: vector::empty<String>(),
            count: 0
        };
        move_to(hackermove, players_registry);
    }

    fun init_player(player: &signer, username: String, name: String){
        let player_info = Player {
            name,
            username,
            bio: string::utf8(b""),
            links: vector::empty<String>(),
            skills: vector::empty<String>(),
            certifications: vector::empty<Certification>(),
            achievements: vector::empty<Achievement>()
        };

        move_to(player, player_info);
    }

    public entry fun register_player(player: &signer, hackermove_addr: address, username: String, name: String) acquires PlayersRegistry {
        let players_registry = borrow_global_mut<PlayersRegistry>(hackermove_addr);
        let player_addr = signer::address_of(player);

        assert!(!players_registry.players.contains(username), E_USER_ALREADY_REGISTERED);
        players_registry.players.add(username, player_addr);
        players_registry.keys.push_back(username);
        players_registry.count += 1;

        init_player(player, username, name);
    }

    public entry fun update_bio(player: &signer, bio: String) acquires Player {
        let player_addr = signer::address_of(player);
        let player = borrow_global_mut<Player>(player_addr);
        player.bio = bio;
    }

    public entry fun update_name(player: &signer, name: String) acquires Player {
        let player_addr = signer::address_of(player);
        let player = borrow_global_mut<Player>(player_addr);
        player.name = name;
    }

    public entry fun add_link(player: &signer, link: String) acquires Player {
        let player_addr = signer::address_of(player);
        let player = borrow_global_mut<Player>(player_addr);

        player.links.push_back(link);
    }

    public entry fun remove_link(player: &signer, link: String) acquires Player {
        let player_addr = signer::address_of(player);
        let player = borrow_global_mut<Player>(player_addr);

        if (player.links.contains(&link)) {
            player.links.remove_value(&link);
        }
    }

    public entry fun add_skill(player: &signer, skill: String) acquires Player {
        let player_addr = signer::address_of(player);
        let player = borrow_global_mut<Player>(player_addr);

        player.skills.push_back(skill);
    }

    public entry fun remove_skill(player: &signer, skill: String) acquires Player {
        let player_addr = signer::address_of(player);
        let player = borrow_global_mut<Player>(player_addr);

        if (player.skills.contains(&skill)) {
            player.skills.remove_value(&skill);
        };
    }

    public entry fun add_certification(player: &signer, title: String, issuer: String, month_exp: String, day_exp: String, year_exp: String) acquires Player {
        let player_addr = signer::address_of(player);
        let player = borrow_global_mut<Player>(player_addr);

        let certification =  Certification {
            title,
            issuer,
            expiration_date: date_formatter(month_exp, day_exp, year_exp)
        };

        player.certifications.push_back(certification);
    }

    public entry fun remove_certification(player: &signer, title: String) acquires Player {
        let player_addr = signer::address_of(player);
        let player = borrow_global_mut<Player>(player_addr);

        let index = 0;

        while (index < player.certifications.length()) {
            let certification_title = player.certifications[index].title;
            if(title == certification_title){
                player.certifications.remove(index);
                break;
            };
            index += 1;
        };
    }

    public entry fun add_achievement(player: &signer, title: String, award: String, month: String, day: String, year: String) acquires Player {
        let player_addr = signer::address_of(player);
        let player = borrow_global_mut<Player>(player_addr);

        let achievement = Achievement{
            title,
            award,
            date: date_formatter(month, day, year)
        };

        player.achievements.push_back(achievement);
    }

    public entry fun remove_achievement(player: &signer, title: String) acquires Player {
        let player_addr = signer::address_of(player);
        let player = borrow_global_mut<Player>(player_addr);

        let index = 0;

        while (index < player.achievements.length()) {
            let achievement_title = player.achievements[index].title;
            if(title == achievement_title){
                player.achievements.remove(index);
                break;
            };
            index += 1;
        };
    }

    #[view]
    public fun get_player_info(player_addr: address): (String, String, String) acquires Player {
        let player = borrow_global<Player>(player_addr);
        (player.name, player.username, player.bio)
    }

    #[view]
    public fun get_player_skills(player_addr: address): vector<String> acquires Player {
        let player = borrow_global<Player>(player_addr);
        player.skills
    }

    #[view]
    public fun get_player_links(player_addr: address): vector<String> acquires Player {
        let player = borrow_global<Player>(player_addr);
        player.links
    }

    #[view]
    public fun get_player_achievements(player_addr: address): vector<Achievement> acquires Player {
        let player = borrow_global<Player>(player_addr);
        player.achievements
    }

    #[view]
    public fun get_player_certifications(player_addr: address): vector<Certification> acquires Player {
        let player = borrow_global<Player>(player_addr);
        player.certifications
    }

    #[view]
    public fun get_all_players_username(hackermove_addr: address): vector<String> acquires PlayersRegistry {
        let players_registry = borrow_global<PlayersRegistry>(hackermove_addr);
        players_registry.keys
    }

    // Unit Tests
    #[test(hackermove=@0xDEADBEEF)]
    public fun test_init_module(hackermove: &signer) acquires PlayersRegistry {
        init_module(hackermove);

        let hackermove_addr = signer::address_of(hackermove);
        let player_registry = borrow_global<PlayersRegistry>(hackermove_addr);

        assert!(player_registry.count == 0, 20);
    }

    #[test(hackermove=@0xDEADBEEF, player=@0x1337)]
    public fun test_register_player(player: &signer, hackermove: &signer) acquires PlayersRegistry, Player {
        init_module(hackermove);

        let hackermove_addr = signer::address_of(hackermove);
        let player_addr = signer::address_of(player);

        let username = string::utf8(b"jdoe1337");
        let name = string::utf8(b"John Doe");

        register_player(player, hackermove_addr, username, name);

        let player_registry = borrow_global<PlayersRegistry>(hackermove_addr);
        assert!(player_registry.count == 1, 21);
        assert!(player_registry.players.contains(username), 22);
        assert!(player_registry.players.borrow(username) == &player_addr, 23);

        let player_info = borrow_global<Player>(player_addr);
        assert!(player_info.username == username, 24);
        assert!(player_info.name == name, 25);
        assert!(player_info.bio.is_empty(), 26);
        assert!(player_info.links.is_empty(), 27);
        assert!(player_info.skills.is_empty(), 28);
        assert!(player_info.achievements.is_empty(), 29);
        assert!(player_info.certifications.is_empty(), 30);
    }

    #[test(player=@0x1337)]
    public fun test_update_bio(player: &signer) acquires Player {
        let username = string::utf8(b"jdoe1337");
        let name = string::utf8(b"John Doe");

        init_player(player, username, name);

        let short_bio = string::utf8(b"Hack Your Way In. Prove Skills. Join Teams.");
        update_bio(player, short_bio);

        let player_addr = signer::address_of(player);
        let player_info = borrow_global<Player>(player_addr);

        assert!(!player_info.bio.is_empty(), 31);
        assert!(player_info.bio == short_bio, 32);
    }

    #[test(player=@0x1337)]
    public fun test_update_name(player: &signer) acquires Player {
        let username = string::utf8(b"jdoe1337");
        let name = string::utf8(b"John Doe");

        init_player(player, username, name);

        let player_addr = signer::address_of(player);
        let player_info = borrow_global<Player>(player_addr);
        assert!(player_info.name == name, 33);

        let new_name = string::utf8(b"Aptos Ninja");
        update_name(player, new_name);
        let player_info = borrow_global<Player>(player_addr);
        assert!(player_info.name == new_name, 34);
    }

    #[test(player=@0x1337)]
    public fun test_add_link(player: &signer) acquires Player {
        let username = string::utf8(b"jdoe1337");
        let name = string::utf8(b"John Doe");

        init_player(player, username, name);

        let player_addr = signer::address_of(player);
        let link = string::utf8(b"aptos.xyz");
        add_link(player, link);

        let player_info = borrow_global<Player>(player_addr);
        assert!(!player_info.links.is_empty(), 35);
        assert!(player_info.links.contains(&link), 36);
    }

    #[test(player=@0x1337)]
    public fun test_remove_link(player: &signer) acquires Player {
        let username = string::utf8(b"jdoe1337");
        let name = string::utf8(b"John Doe");

        init_player(player, username, name);

        let player_addr = signer::address_of(player);
        let link = string::utf8(b"aptos.xyz");
        add_link(player, link);

        let player_info = borrow_global<Player>(player_addr);
        assert!(!player_info.links.is_empty(), 35);
        assert!(player_info.links.contains(&link), 36);

        remove_link(player, link);
        let player_info = borrow_global<Player>(player_addr);
        assert!(player_info.links.is_empty(), 41);
        assert!(!player_info.links.contains(&link), 42);
    }

    #[test(player=@0x1337)]
    public fun test_add_skills(player: &signer) acquires Player {
        let username = string::utf8(b"jdoe1337");
        let name = string::utf8(b"John Doe");

        init_player(player, username, name);

        let player_addr = signer::address_of(player);

        let skill = string::utf8(b"Forensics");
        add_skill(player, skill);

        let skill2 = string::utf8(b"Reverse Engineering");
        add_skill(player, skill2);

        let player_info = borrow_global<Player>(player_addr);
        assert!(!player_info.skills.is_empty(), 37);
        assert!(player_info.skills.contains(&skill), 38);
        assert!(player_info.skills.borrow(1) == &skill2, 39);
    }

    #[test(player=@0x1337)]
    public fun test_remove_skills(player: &signer) acquires Player {
        let username = string::utf8(b"jdoe1337");
        let name = string::utf8(b"John Doe");

        init_player(player, username, name);

        let player_addr = signer::address_of(player);

        let skill = string::utf8(b"Forensics");
        add_skill(player, skill);

        let skill2 = string::utf8(b"Reverse Engineering");
        add_skill(player, skill2);

        let player_info = borrow_global<Player>(player_addr);
        assert!(!player_info.skills.is_empty(), 37);
        assert!(player_info.skills.contains(&skill), 38);
        assert!(player_info.skills.borrow(1) == &skill2, 39);

        remove_skill(player, skill);
        let player_info = borrow_global<Player>(player_addr);
        assert!(!player_info.skills.contains(&skill), 42);
    }

    #[test(player=@0x1337)]
    public fun test_add_achievement(player: &signer) acquires Player {
        let username = string::utf8(b"jdoe1337");
        let name = string::utf8(b"John Doe");

        init_player(player, username, name);

        let player_addr = signer::address_of(player);
        let title = string::utf8(b"Secarmy CTF 2019");

        add_achievement(
            player,
            title,
            string::utf8(b"9th place"),
            string::utf8(b"02"),
            string::utf8(b"05"),
            string::utf8(b"2019")
        );

        let player_info = borrow_global<Player>(player_addr);

        assert!(player_info.achievements.borrow(0).title == title, 40);
        assert!(player_info.achievements.borrow(0).date == string::utf8(b"02/05/2019"));
    }

    #[test(player=@0x1337)]
    public fun test_remove_achievement(player: &signer) acquires Player {
        let username = string::utf8(b"jdoe1337");
        let name = string::utf8(b"John Doe");

        init_player(player, username, name);

        let player_addr = signer::address_of(player);
        let title = string::utf8(b"Hack4Gov CTF 2019");

        add_achievement(
            player,
            title,
            string::utf8(b"3rd place"),
            string::utf8(b"02"),
            string::utf8(b"05"),
            string::utf8(b"2019")
        );

        let player_info = borrow_global<Player>(player_addr);

        assert!(player_info.achievements.borrow(0).title == title, 40);
        assert!(player_info.achievements.borrow(0).date == string::utf8(b"02/05/2019"));

        remove_achievement(player, title);
        let player_info = borrow_global<Player>(player_addr);
        assert!(player_info.achievements.is_empty(), 44);
    }
}
