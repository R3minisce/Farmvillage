export class Resource{

    constructor(label, quantity, maxQuantity) {
        this.initFromObj({label:label,quantity:quantity, max_quantity:maxQuantity});
    }
    initFromObj(o){
        this.label = o.label;
        if(o.quantity !== undefined){
            this.quantity = o.quantity;
        }else{
            this.quantity = 0;
        }
        if(o.max_quantity !== undefined){
            this.max_quantity = o.max_quantity;
        }else{
            this.max_quantity = -1;
        }
    }

    get Label(){
        return this.label;
    }
    set Label(label){
        this.label = label;
    }
    get Quantity(){
        return this.quantity;
    }
    set Quantity(quantity){
        this.quantity = quantity;
    }
    addQuantity(quantity){
        if(this.max_quantity === -1){
            this.quantity += Math.abs(quantity);
        }else{
            if(this.quantity + Math.abs(quantity) > this.max_quantity){
                this.quantity = this.max_quantity;
            }else{
                this.quantity += Math.abs(quantity);
            }
        }
    }
    removeQuantity(quantity){
        if(quantity > this.quantity){
            this.quantity = 0;
        }else{
            this.quantity -= Math.abs(quantity);
        }
    }
    get MaxQuantity(){
        return this.max_quantity;
    }
    set MaxQuantity(maxQuantity){
        this.max_quantity = maxQuantity;
    }
    isFull(){
        return this.quantity >= this.max_quantity;
    }
}
