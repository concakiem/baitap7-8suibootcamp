module game_hero::hero_test {
    use sui::test_scenario;
    use games::hero::{Self, GameInfo, GameAdmin, Hero, Boar};
    
    #[test]
    fun test_slay_monter() {
        use sui::coin;

        let admin = @0xGHCV;
        let player = @0xHJDF;

        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        {
            hero::new_game(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, player);
        {
            let game: GameInfo = test_scenario::take_immutable<GameInfo>(scenario);
            let game_ref: &GameInfo = &game;
            let coin = coin::mint_for_testing(1000, test_scenario::ctx(scenario));
            hero::acquire_hero(game_ref, coin, test_scenario::ctx(scenario));
            test_scenario::return_immutable(game);
        }

        test_scenario::next_tx(scenario, admin);
        {
            let game: GameInfo = test_scenario::take_immutable<GameInfo>(scenario);
            let game_ref: &GameInfo = &game;
            //-> kiem tra sender co' GameAdmin hay ko ?
            let admin_cap: GameAdmin = test_scenario::take_from_sender<GameAdmin>(scenario);
            hero::send_boar(game_ref, &mut admin_cap, 50, 5, player, test_scenario::ctx(scenario));

            test_scenario::return_to_sender(scenario, admin_cap);
            test_scenario::return_immutable(game);
        };
        test_scenario::next_tx(scenario, player);
        {
            let game: GameInfo = test_scenario::take_immutable<GameInfo>(scenario);
            let hero: Hero = test_scenario::take_from_sender<Hero>(scenario);
            let boar: Boar = test_scenario::take_from_sender<Boar>(scenario);
            hero::slay(&game, &mut hero, boar, test_scenario::ctx(scenario));
            test_scenario::return_immutable(game);
            test_scenario::return_to_sender(scenario, hero);
        };
        test_scenario::end(scenario_val);
    }
    
}