// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Spott is AccessControl {
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

    constructor(address _moderator) {
        // _grantRole(DEFAULT_ADMIN_ROLE, moderator);
        moderator = _moderator;
        _grantRole(MODERATOR_ROLE, moderator);
        _grantRole(DEFAULT_ADMIN_ROLE, moderator);
    }

    struct Product {
        uint256 id;
        address vendor;
        string title;
        uint256 price;
        uint256 stock;
        string videoUrl;
        string metadataUri;
        string videoReplayUri;
        bool active;
        string deliveryOption;
    }

    struct Order {
        uint256 id;
        address buyer;
        uint256 productId;
        uint256 quantity;
        uint256 total;
        bool shipped;
        bool delivered;
        bool confirmed;
        bool released;
        bool disputed;
    }

    struct Review {
        address reviewer;
        address vendor;
        uint8 rating;
        string comment;
        uint256 timestamp;
    }

    struct Vendor {
        uint256 id;
        address owner;
        string name;
        string location;
        string category;
        string metadataUri;
        string bio;
        string profileImage;
        bool verified;
        bool exists;
        uint256 createdAt;
        uint256 updatedAt;
    }

    uint256 public productCount;
    uint256 public orderCount;
    uint256 public totalVendors;
    address public moderator;

    mapping(uint256 => Product) public products;
    mapping(address => uint256[]) public vendorProducts;
    mapping(uint256 => Order) public orders;
    mapping(address => uint256[]) public buyerOrders;
    mapping(address => Vendor) public vendors;
    mapping(address => bool) public vendorsWritten;
    mapping(address => Review[]) public vendorReviews;
    mapping(string => address[]) public vendorsByLocation;
    mapping(address => uint256) public reputationScores;

    event ProductAdded(uint256 indexed productId, address indexed vendor);
    event OrderPlaced(uint256 indexed orderId, address indexed buyer, uint256 productId);
    event VendorRegistered(address indexed vendor);
    event ReviewSubmitted(address indexed vendor, address reviewer);

    function registerVendor(
        string memory name,
        string memory location,
        string memory category,
        string memory metadataUri,
        string memory bio,
        string memory profileImage
    ) external {
        require(!vendorsWritten[msg.sender], "Vendor exists");
        require(bytes(name).length > 0 && bytes(location).length > 0, "Incomplete info");

        totalVendors++;
        vendors[msg.sender] = Vendor({
            id: totalVendors,
            owner: msg.sender,
            name: name,
            location: location,
            category: category,
            metadataUri: metadataUri,
            bio: bio,
            profileImage: profileImage,
            verified: false,
            exists: true,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });

        vendorsWritten[msg.sender] = true;
        vendorsByLocation[location].push(msg.sender);
        emit VendorRegistered(msg.sender);
    }

    function verifyVendor(address vendor) external onlyRole(MODERATOR_ROLE) {
        require(vendorsWritten[vendor], "Vendor not registered");
        require(!vendors[vendor].verified, "Vendor already verified");
        require(vendors[vendor].exists, "Vendor does not exist");
        require(msg.sender != vendor, "Cannot verify self");
        require(moderator == msg.sender, "Only moderator can verify");
        vendors[vendor].verified = true;
    }

    function addProduct(
        string memory title,
        uint256 price,
        uint256 stock,
        string memory videoUrl,
        string memory metadataUri,
        string memory videoReplayUri,
        string memory deliveryOption
    ) external {
        require(vendorsWritten[msg.sender], "Not a vendor");

        productCount++;
        products[productCount] = Product({
            id: productCount,
            vendor: msg.sender,
            title: title,
            price: price,
            stock: stock,
            videoUrl: videoUrl,
            metadataUri: metadataUri,
            videoReplayUri: videoReplayUri,
            active: true,
            deliveryOption: deliveryOption
        });

        vendorProducts[msg.sender].push(productCount);
        emit ProductAdded(productCount, msg.sender);
    }

    function placeOrder(uint256 productId, uint256 quantity) external payable {
        Product storage product = products[productId];
        require(product.active, "Inactive product");
        require(product.stock >= quantity, "Out of stock");
        uint256 total = product.price * quantity;
        require(msg.value == total, "Incorrect value");

        product.stock -= quantity;
        orderCount++;
        orders[orderCount] = Order({
            id: orderCount,
            buyer: msg.sender,
            productId: productId,
            quantity: quantity,
            total: total,
            shipped: false,
            delivered: false,
            confirmed: false,
            released: false,
            disputed: false
        });

        buyerOrders[msg.sender].push(orderCount);
        emit OrderPlaced(orderCount, msg.sender, productId);
    }

    function submitReview(uint256 orderId, uint8 rating, string memory comment) external {
        require(rating >= 1 && rating <= 5, "Invalid rating");
        Order storage order = orders[orderId];
        require(order.buyer == msg.sender, "Not buyer");
        require(order.confirmed, "Not confirmed");

        address vendor = products[order.productId].vendor;
        vendorReviews[vendor].push(
            Review({reviewer: msg.sender, vendor: vendor, rating: rating, comment: comment, timestamp: block.timestamp})
        );

        reputationScores[vendor] += rating;
        emit ReviewSubmitted(vendor, msg.sender);
    }

    function getVendorsByLocation(string memory loc) external view returns (address[] memory) {
        return vendorsByLocation[loc];
    }

    function getVendorScore(address vendor) external view returns (uint256) {
        return reputationScores[vendor];
    }

    function getVendor(address vendor) external view returns (Vendor memory ve) {
        Vendor storage ve = vendors[vendor];
        return (ve);
    }

    function getOwner() external view returns (address) {
        return moderator;
    }
}
