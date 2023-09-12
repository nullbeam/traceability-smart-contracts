// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import "./base-contract.sol";

contract Traceability is BaseContract {

    event NewLotProccess(uint indexed lotId, string indexed processId, address sender, string indexed companyId);

    constructor() {
        owner = payable(msg.sender);
        count = 1;
    }

    uint count;

    struct LotProccess {
        uint8 processId;
        string companyId;
        uint operationStartDate;
        uint operationEndDate;
        string location;
        string additionalInformation;
        address addedBy;
        uint lotId;
        bool isValid;
        // url image (ToDo)
    }

    struct Lot {
        uint id;
        uint8 currentProcess;
        address createdBy;
        bool isValid;
    }

    struct Company {
        string id;
        string name;
    }

    mapping(uint => Lot) public lotMap;
    mapping(string => LotProccess) public lotProcessMap;
    Company[] public companies;

    function getLotById(uint _id) public view returns(Lot memory) {
        return lotMap[_id];
    }

    function getLotProccessById(string memory _id) public view returns(LotProccess memory) {
        return lotProcessMap[_id];
    }

    function getCompanies() public view returns(Company[] memory) {
        return companies;
    }

    function insertCompany(string memory _id, string memory _name) public onlyOwner {
        Company memory newCompany = Company(_id, _name);
        companies.push(newCompany);
    }

    function insertLotProcess(
        uint8 _currentProcess,
        string memory _companyId,
        uint _operationStartDate,
        uint _operationEndDate,
        string memory _location,
        string memory _additionalInformation,
        uint _lotId
    ) public {
        require (_lotId > 0, "Process is not valid");
        if (lotMap[_lotId].isValid == true) {
            string memory keyLotProcess = string.concat(Strings.toString(_lotId), "-", Strings.toString(_currentProcess));
            require (lotProcessMap[keyLotProcess].isValid == true, "Process is not valid");
            uint8 newProcessId = _currentProcess + 1;
            keyLotProcess = string.concat(Strings.toString(count), "-", Strings.toString(newProcessId));
            LotProccess memory newLotProcess = LotProccess(newProcessId, _companyId, _operationStartDate, _operationEndDate, _location, _additionalInformation, msg.sender, _lotId, true);
            lotProcessMap[keyLotProcess] = newLotProcess;
            lotMap[_lotId].currentProcess = newProcessId;
            emit NewLotProccess(_lotId, keyLotProcess, msg.sender, _companyId);
        } else {
            uint8 newProcessId = 1;
            string memory keyLotProcess = string.concat(Strings.toString(count), "-", Strings.toString(newProcessId));
            Lot memory newLot = Lot(count, newProcessId, msg.sender, true);
            LotProccess memory newLotProcess = LotProccess(newProcessId, _companyId, _operationStartDate, _operationEndDate, _location, _additionalInformation, msg.sender, count, true);
            lotMap[count] = newLot;
            lotProcessMap[keyLotProcess] = newLotProcess;
            emit NewLotProccess(count, keyLotProcess, msg.sender, _companyId);
            count += 1;
        }
    }
}
