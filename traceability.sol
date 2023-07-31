// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract Traceability {

    // siembra
    struct Sown {
        uint date;
        uint8 typeSeed;
        string rotation;
        uint32 lotNumber;
    }

     // cosecha
    struct Harvest {
        uint date;
        uint8 abono;
        string dotacion;
        string madurez;
        uint8 size;
    }

    // almacenado
    struct Stored {
        uint32 packageNumber;
        uint incomeDate;
        uint exitDate;
        uint8 temperature;
    }

    // logistica
    struct Logistic {
        uint packageId;
        uint incomeDate;
        string incomePlace;
        uint exitDate;
        string exitPlace;
    }

    Sown[] public sownArr;
    Stored[] public storedArr;
    Logistic[] public logisticArr;
    Harvest[] public harvestArr;

    /* =====================
        Inserts
    ======================*/

    function insertSown(uint _date, uint8 _typeSeed, string memory _rotation, uint32 _lotNumber) public {
        Sown memory sown = Sown(_date, _typeSeed, _rotation, _lotNumber);
        sownArr.push(sown);
    }

    function insertStored(uint32 _packageNumber, uint _incomeDate, uint _exitDate, uint8 _temperature) public {
        require (_incomeDate >= _exitDate, "exitDate can't less than incomeDate");
        Stored memory stored = Stored(_packageNumber, _incomeDate, _exitDate, _temperature);
        storedArr.push(stored);
    }

    function insertLogistic(uint _packageId, uint _incomeDate, string memory incomePlace, uint _exitDate, string memory _exitPlace) public {
        require (_incomeDate >= _exitDate, "exitDate can't less than incomeDate");
        Logistic memory logistic = Logistic(_packageId, _incomeDate, incomePlace, _exitDate, _exitPlace);
        logisticArr.push(logistic);
    }

    function insertHarvest(uint _date, uint8 _abono, string memory _dotacion, string memory _madurez, uint8 _size) public {
        Harvest memory harvest = Harvest(_date, _abono, _dotacion, _madurez, _size);
        harvestArr.push(harvest);
    }

     /* =====================
        Gets
    ======================*/

    function getSown() public view returns(Sown[] memory) {
        return sownArr;
    }

    function getStored() public view returns(Stored[] memory) {
        return storedArr;
    }

    function getLogistic() public view returns(Logistic[] memory) {
        return logisticArr;
    }

    function getHarvest() public view returns(Harvest[] memory) {
        return harvestArr;
    }
}
