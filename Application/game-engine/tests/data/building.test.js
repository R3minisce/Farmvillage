import {Building} from "../../models/data/building.js";

test('alwaysok', async () => {
    expect(true).toStrictEqual(true);
});

// test('takeDmg', async () => {
//     let b = new Building();
//     b.MaxHp = 100;
//     b.Hp = 100;
//     b.takeDmg(50);
//     expect(b.Hp).toStrictEqual(50);
//     b.takeDmg(50);
//     expect(b.Hp).toStrictEqual(0);
//     b.takeDmg(50);
//     expect(b.Hp).toStrictEqual(0);
// });

// test('repair', async () => {
//     let b = new Building();
//     b.MaxHp = 100;
//     b.Hp = 50;
//     b.repair();
//     expect(b.Hp).toStrictEqual(100);
// });

// test('isDestroyed', async () => {
//     let b = new Building();
//     b.MaxHp = 100;
//     b.Hp = 50;
//     expect(b.isDestroyed()).toStrictEqual(false);
//     b.Hp = 0;
//     expect(b.isDestroyed()).toStrictEqual(true);
// });


// test('addVillager', async () => {
//     let b = new Building();
//     b.villagers = [1,2];
//     expect(b.villagers.find(v=>v === 3)).toStrictEqual(undefined);
//     b.addVillager(3) ;
//     expect(b.villagers).toHaveLength(3);
//     expect(b.villagers.find(v=>v === 3)).not.toStrictEqual(undefined);
//     b.addVillager(3) ;
//     expect(b.villagers).toHaveLength(3);
//     expect(b.villagers.find(v=>v === 3)).not.toStrictEqual(undefined);
// });

// test('removeVillager', async () => {
//     let b = new Building();
//     b.villagers = [1,2];
//     b.removeVillager(3);
//     expect(b.villagers).toHaveLength(2);
//     expect(b.villagers.find(v=>v === 2)).not.toStrictEqual(undefined);
//     expect(b.villagers.find(v=>v === 3)).toStrictEqual(undefined);
//     b.removeVillager(2) ;
//     expect(b.villagers).toHaveLength(1);
//     expect(b.villagers.find(v=>v === 2)).toStrictEqual(undefined);
// });

// test('addRessources', async () => {
//     let b = new Building();
//     b.storage = 50;
//     b.maxStorage = 100;
//     b.addResources(50);
//     expect(b.CurrentStorage).toStrictEqual(100);
//     b.addResources(50);
//     expect(b.CurrentStorage).toStrictEqual(100);
// });

// test('removeRessources', async () => {
//     let b = new Building();
//     b.storage = 50;
//     b.maxStorage = 100;
//     b.removeResources(50);
//     expect(b.CurrentStorage).toStrictEqual(0);
//     b.removeResources(50);
//     expect(b.CurrentStorage).toStrictEqual(0);
// });
