export class ExternalEvent{

    initEvent(label, level, quantity){
        if(label === undefined || (level === undefined && quantity === undefined))
            return false;
        this.label = label;
        this.quantity = quantity;
        this.level = level;
        return true;
    }
    get Label(){
        return this.label;
    }
    get Level(){
        return this.level;
    }
    get Quantity(){
        return this.quantity;
    }

}
