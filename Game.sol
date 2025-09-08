pragma solidity ^0.5.0;

contract JiandaoShitouBu {
    uint numberOfPlayers = 0;
    uint id = 0;
    uint mygo = 0;
    uint i = 1;
    //为返还玩家筹码设置了时间判断必要的变量
    uint waitingtime = 1 days;
    uint jointime;
    
    //将玩家的id和出拳结果对应并写入三维数组
    mapping(uint => uint) thegoof;
    //将玩家的id和各自的地址，筹码金额建立联系，便利之后的转账操作
    mapping(uint => uint) playervalue; 
    mapping(uint => address payable) playeraddress;
    mapping(address => uint) theaddressof;
    
    //筹码金额要求
    modifier bet(uint _gobetting) {
        require(_gobetting >= 2 ether);
        _;
    }
    //不允许同一玩家重复出拳
    modifier nogoingtwice() {
        while (i <= numberOfPlayers && id > 0){
            require(msg.sender != playeraddress[i]);
            i++;
        }
        _;
    }
    //进行胜负判断的三维数组
    uint[3][3][3] whoWin = [[[0,3,4],[2,6,0],[5,0,1]],[[1,5,0],[4,0,3],[0,2,6]],[[6,0,2],[0,1,5],[3,4,0]]];
    //提醒玩家游戏规则
    function checkbeforejoin() public returns(string memory) {
        return ("你可以选择出“0”代表剪刀，“1”代表石头，“2”代表布。在参与游戏时，您至少需要下注2 ether，否则无法加入游戏，您不能重复出拳。一天之内若没有足够玩家加入，将退回筹码");
    }
    function join(uint go) public payable bet(msg.value) nogoingtwice() returns(string memory, uint) {
        require(numberOfPlayers < 3);
        id = ++numberOfPlayers;
        _join(go);
        thegoof[id] = mygo;
        playervalue[id] = msg.value;
        playeraddress[id] = msg.sender;
        theaddressof[msg.sender] = id;
        if(id == 1) {
            jointime = now;
            return ("您是玩家1", jointime);
        }else if(id == 2) {
            return ("您是玩家2", jointime);
        }else if(id == 3) {
            return ("您是玩家3", jointime);
        }
    }
    function _join(uint _go) private {
        require(_go<=2 && _go >= 0);
        mygo = _go;
    }
    //判断胜者的同时返还筹码
    function whowin() public payable returns(string memory) {
        if(now >= jointime + waitingtime) {
            playeraddress[theaddressof[msg.sender]].transfer(playervalue[theaddressof[msg.sender]]);
            return ("游戏玩家不足，游戏筹码已经返还，请查看账户余额");
        }else if(now <= jointime + waitingtime && numberOfPlayers == 3) {
        uint winner = whoWin[thegoof[1]][thegoof[2]][thegoof[3]];
        if(winner == 0) {
            playeraddress[theaddressof[msg.sender]].transfer(playervalue[theaddressof[msg.sender]]);
            return "平局，没有赢家，请查看账户余额";
        }else if(winner == 4) {
            playeraddress[1].transfer(playervalue[1] + 1 ether); 
            playeraddress[2].transfer(playervalue[2] + 1 ether);
            playeraddress[3].transfer(playervalue[3] - 2 ether);
            return "赢家是玩家1和玩家2，请查看账户余额";
        }else if(winner == 5) {
            playeraddress[1].transfer(playervalue[1] + 1 ether); 
            playeraddress[2].transfer(playervalue[2] - 2 ether);
            playeraddress[3].transfer(playervalue[3] + 1 ether);
            return "赢家是玩家1和玩家3，请查看账户余额";
        }else if(winner == 6) {
            playeraddress[1].transfer(playervalue[1] - 2 ether); 
            playeraddress[2].transfer(playervalue[2] + 1 ether);
            playeraddress[3].transfer(playervalue[3] + 1 ether);
            return "赢家是玩家2和玩家3，请查看账户余额";
        }else if(winner == 1) {
            playeraddress[1].transfer(playervalue[1] + 2 ether); 
            playeraddress[2].transfer(playervalue[2] - 1 ether);
            playeraddress[3].transfer(playervalue[3] - 1 ether);
            return "赢家是玩家1，请查看账户余额";
        }else if(winner == 2) {
            playeraddress[1].transfer(playervalue[1] - 1 ether); 
            playeraddress[2].transfer(playervalue[2] + 2 ether);
            playeraddress[3].transfer(playervalue[3] - 1 ether);
            return "赢家是玩家2，请查看账户余额";
        }else if(winner == 3) {
            playeraddress[1].transfer(playervalue[1] - 1 ether); 
            playeraddress[2].transfer(playervalue[2] - 1 ether);
            playeraddress[3].transfer(playervalue[3] + 2 ether);
            return "赢家是玩家3，请查看账户余额";
        }else if(now < jointime + waitingtime && numberOfPlayers <3) {
            return "游戏玩家不足，请您耐心等待";
        }
_nextgame();
    }
}
        //游戏结束后可以马上进行下一轮游戏
    function _nextgame() private {
        id = 0;
        numberOfPlayers = 0;
        mygo = 0;
        i = 1;
    } 
}
