// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract Traceability is Ownable, AccessControl {
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");
    // bytes32 public constant MANAGEMENT_ROLE = keccak256("USER_ROLE");

    event NewLotProccess(uint indexed lotId, uint8 indexed processId, address sender);

    constructor() {
        count = 1;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    uint count;

    struct LotProcess {
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
        string documentId;
        string name;
        string location;
        uint8[] processes;
    }

    mapping(uint => Lot) public lotMap;
    mapping(string => LotProcess) public lotProcessMap;
    mapping(string => uint) public lotProcessByCompanyMap;
    Company[] public companies;

    function getLotById(uint _id) public view returns(Lot memory) {
        return lotMap[_id];
    }

    function getLotProccessById(string memory _id) public view returns(LotProcess memory) {
        return lotProcessMap[_id];
    }

    function getLotProccessByCompany(string memory _id) public view returns(LotProcess[] memory) {
        uint indexLot = lotProcessByCompanyMap[_id];
        require (indexLot != 0, "Process not found");
        Lot memory lot = lotMap[indexLot];
        uint8 currentProcess = lot.currentProcess;
        LotProcess[] memory lotProcesses = new LotProcess[](currentProcess);
        for(uint8 i = 1; i <= currentProcess; i++) {
            string memory keyLotProcess = string.concat(Strings.toString(indexLot), "-", Strings.toString(i));
            lotProcesses[i] = lotProcessMap[keyLotProcess];
        }

        return lotProcesses;
    }

    function getCompanies() public view returns(Company[] memory) {
        return companies;
    }

    function insertCompany(string memory _documentId, string memory _name, string memory _location, uint8[] memory _processes) public onlyRole(MANAGEMENT_ROLE) {
        Company memory newCompany = Company(_documentId, _name, _location, _processes);
        companies.push(newCompany);
    }

    function deleteCompany(uint8 _index, string memory _documentId) public onlyRole(MANAGEMENT_ROLE) {
        require(_index < companies.length, "index out of bound");
        Company memory company = companies[_index];
        require(keccak256(abi.encodePacked(company.documentId)) == keccak256(abi.encodePacked(_documentId)), string.concat("Invalid document id for ", _documentId));
        for (uint i = _index; i < companies.length - 1; i++) {
            companies[i] = companies[i + 1];
        }
        companies.pop();
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
        if (lotMap[_lotId].isValid == true) {
            string memory keyLotProcess = string.concat(Strings.toString(_lotId), "-", Strings.toString(_currentProcess));
            require (lotProcessMap[keyLotProcess].isValid == true, "Process is not valid");
            uint8 newProcessId = _currentProcess + 1;
            keyLotProcess = string.concat(Strings.toString(_lotId), "-", Strings.toString(newProcessId));
            LotProcess memory newLotProcess = LotProcess(newProcessId, _companyId, _operationStartDate, _operationEndDate, _location, _additionalInformation, msg.sender, _lotId, true);
            lotProcessMap[keyLotProcess] = newLotProcess;
            lotMap[_lotId].currentProcess = newProcessId;
            lotProcessByCompanyMap[_companyId] = _lotId;
            emit NewLotProccess(_lotId, newProcessId, msg.sender);
        } else {
            uint8 newProcessId = 1;
            string memory keyLotProcess = string.concat(Strings.toString(count), "-", Strings.toString(newProcessId));
            Lot memory newLot = Lot(count, newProcessId, msg.sender, true);
            LotProcess memory newLotProcess = LotProcess(newProcessId, _companyId, _operationStartDate, _operationEndDate, _location, _additionalInformation, msg.sender, count, true);
            lotMap[count] = newLot;
            lotProcessMap[keyLotProcess] = newLotProcess;
            lotProcessByCompanyMap[_companyId] = count;
            emit NewLotProccess(count, newProcessId, msg.sender);
            count += 1;
        }
    }
}