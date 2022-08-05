export class Item{
    initFromObj(o){
        this.label = o.label;
        this.type = o.type;
        this.desc = o.desc;
        this.target = o.target;
        this.ratio = o.ratio;
        this.price = o.price;
        this._id = o._id;
        this.duration = o.duration;
        this.quantity = 0;
    }
    get Price(){
        return this.price;
    }
    set Price(price){
        this.price = price;
    }
    get Label(){
        return this.label;
    }
    get Type(){
        return this.type;
    }
    get Desc(){
        return this.desc
    }
    get Target(){
        return this.target;
    }
    get Ratio(){
        return this.ratio;
    }
    get Id(){
        return this._id;
    }
    set Id(id){
        this._id = id;
    }
    get Duration(){
        return this.duration;
    }
    get Quantity(){
        return this.quantity;
    }
    set Quantity(quantity){
        this.quantity = quantity;
    }

}
