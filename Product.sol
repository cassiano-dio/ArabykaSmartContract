// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Products {

    address public owner;
    uint256 public activeProductCounter = 0;
    uint256 public inactiveProductCounter = 0;
    uint256 private productCounter = 0;

    enum Deactivated { NO, YES }

    struct ProductStruct {
        uint256 productId;
        uint256 productCounter;
        string name;
        uint256 classification;
        string company;
        Deactivated deleted;
        uint256 created;
        uint256 updated;
    }

    ProductStruct[] activeProducts;
    ProductStruct[] inactiveProducts;

    event Action (
        uint256 productId,
        string actionType,
        Deactivated deleted,
        uint256 created
    );

    modifier ownerOnly(){
        require(msg.sender == owner, "Owner reserved only");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Criando um novo produto

    function createProduct(
        uint256 productId,
        string memory name,
        uint256 classification,
        string memory company
    ) external returns (bool) {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(classification >= 0, "Classification cannot be empty");
        require(bytes(company).length > 0, "Company cannot be empty");

        productCounter++;
        activeProductCounter++;

        activeProducts.push(
            ProductStruct(
                productId,
                productCounter,
                name,
                classification,
                company,
                Deactivated.NO,
                block.timestamp,
                block.timestamp
            )
        );

        emit Action (
            productCounter,
            "PRODUCT CREATED",
            Deactivated.NO,
            block.timestamp
        );

        return true;
    }

    // Atualizando um produto
    
    function updateProduct(
        uint256 productId,
        string memory name,
        uint256 classification,
        string memory company
    ) external returns (bool) {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(classification > 0, "Classification cannot be empty");
        require(bytes(company).length > 0, "Company cannot be empty");

        for(uint i = 0; i < activeProducts.length; i++) {
            if(activeProducts[i].productId == productId) {
                activeProducts[i].name = name;
                activeProducts[i].classification = classification;
                activeProducts[i].company = company;
                activeProducts[i].updated = block.timestamp;
            }
        }

        emit Action (
            productId,
            "PRODUCT UPDATED",
            Deactivated.NO,
            block.timestamp
        );

        return true;
    }

    // Buscando um produto

    function showProduct(
        uint256 productId
    ) external view returns (ProductStruct memory) {
        ProductStruct memory product;
        for(uint i = 0; i < activeProducts.length; i++) {
            if(activeProducts[i].productId == productId) {
                product = activeProducts[i];
            }
        }
        return product;
    }

    // Listando produtos ativos

    function getProducts() external view returns (ProductStruct[] memory) {
        return activeProducts;
    }

    // Listando produtos deletados

    function getDeletedProduct() ownerOnly external view returns (ProductStruct[] memory) {
        return inactiveProducts;
    }

    // Deletando um produto

    function deleteProduct(uint256 productId) ownerOnly external returns (bool) {
        

        for(uint i = 0; i < activeProducts.length; i++) {
            if(activeProducts[i].productId == productId) {
                activeProducts[i].deleted = Deactivated.YES;
                activeProducts[i].updated = block.timestamp;
                inactiveProducts.push(activeProducts[i]);
                delete activeProducts[i];
            }
        }

        inactiveProductCounter++;
        activeProductCounter--;

        emit Action (
            productId,
            "POST DELETED",
            Deactivated.YES,
            block.timestamp
        );

        return true;
    }
}
