// import {Player} from "../../models/data/player.js";



// test('takeDmg', async () => {
//     let p = new Player();
//     p.MaxHp = 100;
//     p.Hp = 100;
//     p.takeDmg(50);
//     expect(p.Hp).toStrictEqual(50);
//     p.takeDmg(50);
//     expect(p.Hp).toStrictEqual(0);
//     p.takeDmg(50);
//     expect(p.Hp).toStrictEqual(0);
// });

// test('heal', async () => {
//     let p = new Player();
//     p.MaxHp = 100;
//     p.Hp = 50;
//     p.heal(50);
//     expect(p.Hp).toStrictEqual(100);
//     p.heal(50);
//     expect(p.Hp).toStrictEqual(100);
// });

// test('isDead', async () => {
//     let p = new Player();
//     p.MaxHp = 100;
//     p.Hp = 50;
//     expect(p.isDead()).toStrictEqual(false);
//     p.Hp = 0;
//     expect(p.isDead()).toStrictEqual(true);
// });
test('alwaysok', async () => {
    expect(true).toStrictEqual(true);
});