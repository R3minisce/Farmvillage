export class GameEvent {
    constructor(label, duration, frequency, probability, level) {
        this.label = label;
        this.duration = duration;
        this.frequency = frequency;
        this.probability = probability;
        this.level = level;

    }
    get Label(){
        return this.label;
    }
    get Duration(){
        return this.duration;
    }
    get Frequency(){
        return this.frequency;
    }
    get Probability(){
        return this.probability;
    }
    get Level(){
        return this.level;
    }
}