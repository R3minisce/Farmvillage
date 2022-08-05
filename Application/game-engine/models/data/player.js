import {Resource} from "./resource.js";

export class Player {

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
        this._id = o._id;
        this.user_account = o.user_account;
        //this.position = o.position;
        this.hp = o.hp;
        this.max_hp = o.max_hp;
        this.inventory = [];
        if(o.inventory !== undefined){
            for(let item of o.inventory){
                let r = new Resource();
                r.initFromObj(item);
                this.inventory.push(r);
            }
        }

        /*
            "inventory": [
                {
                  "label": "string",
                  "quantity": 0,
                  "max_quantity": 0
                }
            ]
         */
    }
    initInventoryFromObjArray(itemArray){
        this.inventory = [];
        for(let item of itemArray){
            let r = new Resource();
            r.initFromObj(item);
            this.inventory.push(r);
        }
    }

    get Id(){
        return this._id;
    }

    get Position(){
        return this.position;
    }

    set Position(pos){
        this.position = pos;
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
    get Inventory(){
        return this.inventory;
    }
    set Inventory(inventory){
        this.inventory = inventory;
    }

    get MaxHp(){
        return this.max_hp;
    }

    set MaxHp(maxHp){
        this.max_hp = maxHp;
    }

    addResource(label, quantity){
        let item = this.inventory.find(i=>i.label === label.toUpperCase());
        if(item !== undefined){
            item.addQuantity(Math.abs(quantity));
        }else{
            item = new Resource();
            item.label = label.toUpperCase();
            item.quantity = 0;
            item.max_quantity = -1;
            item.addQuantity(Math.abs(quantity));
            this.inventory.push(item);
        }
    }

    removeResource(label, quantity){
        let item = this.inventory.find(i=>i.label === label.toUpperCase());
        if(item !== undefined){
            item.removeQuantity(Math.abs(quantity));
        }/*else{
            item = new Resource();
            item.label = label.toUpperCase();
            item.quantity = 0;
            item.max_quantity = -1;
            this.inventory.push(item);
        }*/
    }

    isInventoryFull(){
        let val = 0;
        for(let r of this.inventory){
            if(r.Label !== "GOLD"){
                val += r.quantity;
            }
        }
        return val >= 500;
    }
    countResource(label){
        let resource =  this.inventory.find(i=>i.label === label.toUpperCase());
        if(resource !== undefined){
            return resource.Quantity;
        }
        return 0;
    }
}
