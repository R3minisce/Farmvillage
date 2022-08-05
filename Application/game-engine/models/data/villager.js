export class Villager{

    initFromObj(o){
        this.id = o.id;
    }
    get Id(){
        return this.id;
    }
    set Id(id){
        this.id = id;
    }
    /*
    initFromObj(o){
        this.name = o.name;
        this.hp = o.hp;
        this.max_hp = o.max_hp;
        this.alive = o.alive;
    }


    get Name(){
        return this.name;
    }
    get Hp(){
        return this.hp;
    }
    get MaxHp(){
        return this.max_hp;
    }
    get IsAlive(){
        return this.alive;
    }*/
}