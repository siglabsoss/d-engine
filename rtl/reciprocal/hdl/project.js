module.exports = {
    "top": "reciprocal",
    "topFile": "reciprocal.v",
    "clk": "clk",
    "reset_n": "reset_n",
    "targets": [
        {
            "data": "t_0_dat",
            "valid": "t_0_req",
            "ready": "t_0_ack",
            "width": 16,
            "length": 16
        }
    ],
    "initiators": [
        {
            "data": "i_16_dat",
            "valid": "i_16_req",
            "ready": "i_16_ack",
            "width": 16,
            "length": 16
        }
    ]
};