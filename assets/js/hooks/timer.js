export default {
    timeout() { return new Date(this.el.dataset.timeout + "+0000") },

    mounted() {
        this.interval = setInterval(() => this.setTimerValue(), 1000);
    },

    updated() {
        this.setTimerValue()
    },

    destroy() {
        clearInterval(this.interval)
    },

    setTimerValue() {
        let seconds = (this.timeout().getTime() - new Date().getTime()) / 1000
        console.log(seconds);
        const minutes = Math.floor(seconds / 60)
        seconds = Math.floor(seconds - minutes * 60)

        this.el.innerText = `${minutes}:${seconds < 10 ? '0' + seconds : seconds}`
    }
}
