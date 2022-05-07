// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CFT is Ownable
    // CFT = Collaborative Fungible Token
{
    // Owner of CFT

    address private ownerCFT;
    uint256 private price;

    event transfer(address indexed from, address indexed to, uint256 indexed price);
    event transferApproval(address indexed from, address indexed to, uint256 indexed price);

    // Composition of the CFT & Owners of pixels

    address[30][30] private owners;
    string[30][30] private pixels;
    uint[30][30] private prices;

    event newPixelOwner(address indexed newOwner, uint indexed coordX, uint indexed coordY);
    event newPixelOwnerApproval(address indexed newOwner, uint indexed coordX, uint indexed coordY);

    constructor(address _owner, uint256 _price){
        ownerCFT = _owner;
        price = _price;
    }

    // CFT Functions

    function buyCFT(address to, uint256 _price) external
        // Buy CFT
    {
        require(_price >= price, "Insufficient funds");
        emit transfer(msg.sender, to, _price);
        emit transferApproval(msg.sender, to, _price);
    }

    function setNewPriceCFT(uint256 _price) external onlyOwner
        // Setter new price for CFT
    {
        price = _price;
    }

    // La unica funcion que falta:
    // Una funcion para que cuando se venda el CFT, se reparta la ganancia entre todos los owners
        // Vendria bien una libreria o algo para que junte y sume si una address tiene varios pixeles para ahorrar numero de transacciones

    // Token functions

    function buyPixel(uint coordX, uint coordY) payable external
        //  Buy Pixel
    {
        require(msg.value >= prices[coordX][coordY] && prices[coordX][coordY] != 0, "Very low quantity or is it not for sale");
        payable(owners[coordX][coordY]).transfer(msg.value);
        owners[coordX][coordY] = msg.sender;
        prices[coordX][coordY] = 0;

        emit newPixelOwner(msg.sender, coordX, coordY);
        emit newPixelOwnerApproval(msg.sender, coordX, coordY);
    }

    function sellPixel(uint _price, uint coordX, uint coordY) external
        //  Sell Pixel
    {
        require(owners[coordX][coordY] == msg.sender, "You are not the owner");
        prices[coordX][coordY] = _price*100000;
    }

    function cancelSellPixel(uint coordX, uint coordY) external
        // Cancel the sale of a pixel
    {
        require(owners[coordX][coordY] == msg.sender && prices[coordX][coordY] >= 1, "You are not the owner");
        prices[coordX][coordY] = 0;
    }

    function setNewColor(string memory color, uint coordX, uint coordY) external
        //  The owner can change the color of his pixel
    {
        require(owners[coordX][coordY] == msg.sender, "You are not the owner");
        pixels[coordX][coordY] = color;
    }

    function drawPixel(string memory color, uint coordX, uint coordY) external
        //  Color a pixel, and save data like the owner, and the color
    {
        require(checkPixel(coordX, coordY) == false && coordX < 30 && coordY < 30, "Token Complete");
        owners[coordX][coordY] = msg.sender;
        pixels[coordX][coordY] = color;

    }

    function checkPixel(uint coordX, uint coordY) private view returns(bool)
        //  Check if there is any pixel without owner, if not, block the modifications
        //  This way of ending the CFT can be changed to a time limit for example
    {
        if(owners[coordX][coordY]==address(0)){
            return false;
        }
        return true;
    }

    function checkIsComplete() external view returns(bool)
        //  Check if there is any pixel without owner, if not, block the modifications
        //  This way of ending the CFT can be changed to a time limit for example
    {
        for(uint i=0; i<30; i++){
            for(uint j=0; j<30; j++){
                if(owners[i][j]==address(0)){
                    return false;
                }
            }
        }
        return true;
    }

    // Getters

    function getOwners() external view returns(address[30][30] memory)
        // Returns the array of pixel owners
    {
        return owners;
    }

    function getColors() external view returns(string[30][30] memory)
        // Returns the color matrix of the CFT
        // This is the function that should be called to build the CFT
    {
        return pixels;
    }

    function getPrices() external view returns(uint[30][30] memory)
        // Returns the prices matrix of the CFT
    {
        return prices;
    }

    function getOwnPixels(address _owner) external view returns(uint)
        // Returns the number of pixels that msg.sender has
    {
        uint cont=0;
        for(uint i=0; i<30; i++){
            for(uint j=0; j<30; j++){
                if(owners[i][j]==_owner){
                    cont++;
                }
            }
        }
        return cont;
    }

}
