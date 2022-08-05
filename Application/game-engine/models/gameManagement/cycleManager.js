import { Utils } from "../utils/utils.js";
import axios from "axios";
import { ApiConfig } from "../../services/apiConfig.js";

export class CycleManager {
    constructor() {
        this.loops = [];
        this.weather = "Clear";
        this.day = "Day";
    }
    startCycles(io) {
        this.cycleWeather(io);
        this.cycleDay(io);
    }
    cycleWeather(io) {
        let self = this;
        this.loops.push(setInterval(function () {
            self.updateWeather(io).then();
        }, 124901));
    }
    cycleDay(io) {
        let self = this;
        this.loops.push(setInterval(function () {
            self.updateDay(io);
        }, 304732));
    }
    // https://openweathermap.org/weather-conditions
    async updateWeather(io) {
        let lat = Utils.getRandomLat();
        let lon = Utils.getRandomLong();
        let result = await axios.get("http://api.openweathermap.org/data/2.5/weather?lat=" + lat + "&lon=" + lon + "&appid=" + ApiConfig.OPENWEATHERAPIKEY).catch(e => {
        });
        if (result !== undefined) {
            try {
                this.weather = result.data.weather[0].main;
                io.emit("weather update", this.weather);
            } catch (e) { }
        }

    }
    updateDay(io) {
        this.day === "Day" ? this.day = "Night" : this.day = "Day";
        io.emit("day update", this.day);
    }

    close() {
        for (let l of this.loops) {
            clearInterval(l);
        }
    }
    get WeatherInfo() {
        return this.weather;
    }
    get DayInfo() {
        return this.day;
    }
}
