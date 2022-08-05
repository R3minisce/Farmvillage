export class AI {

    takeDmg(dmg){
        this.Hp -= dmg;
    }

    heal(hp){
        this.Hp +=hp;
    }

    isDead(){
        return this.Hp <= 0;
    }


    initFromObj(o){
        this.id = o.id;
        this.hp = o.hp;
        this.max_hp = o.max_hp;
        this.position = o.position;
        this.direction = o.direction;
        this.type = o.type;
        if(o.pos_x !== undefined){
            this.pos_x = o.pos_x;
        }else{
            this.pos_x = o.position.x;
        }
        if(o.pos_y!== undefined){
            this.pos_y = o.pos_y;
        }else{
            this.pos_y = o.position.y;
        }
    }

    get Id(){
        return this.id;
    }

    get Position(){
        return this.position;
    }

    set Position(pos){
        this.position = pos;
        this.pos_y = pos.y;
        this.pos_x = pos.x;
    }
    get Direction(){
        return this.direction;
    }
    set Direction(direction){
        this.direction = direction;
    }

    get Hp(){
        return this.hp;
    }

    set Hp(hp){
        if(hp<0)
            hp = 0
        if(hp>this.MaxHp)
            hp = this.MaxHp;
        this.hp = hp;
    }

    get MaxHp(){
        return this.max_hp;
    }

    set MaxHp(maxHp){
        this.max_hp = maxHp;
    }
    get Type(){
        return this.type;
    }
    set Type(type){
        this.type = type;
    }
}
