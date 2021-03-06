import UIKit
import XCTest
import TwoLevelCache

fileprivate let TestsSampleImagePath = "1x1.png"
fileprivate let TestsSampleImageUrl = "https://nzigen.com/static/img/common/logo.png"

class Tests: XCTestCase {
    
    func testFindingWithDownloaderOrCaches() {
        let cache = generateImageCache()
        let expectation0 =
            self.expectation(description: "downloading an image")
        let expectation1 =
            self.expectation(description: "finding an image from memory cache")
        let expectation2 =
            self.expectation(description: "finding an image from file cache")
        let url = TestsSampleImageUrl + "?v=\(Date().timeIntervalSince1970)"
        cache.findObject(forKey: url) { (image, status) in
            XCTAssertNotNil(image)
            XCTAssertEqual(status, TwoLevelCacheHitStatus.downloader)
            expectation0.fulfill()
            cache.findObject(forKey: url) { (image, status) in
                XCTAssertNotNil(image)
                XCTAssertEqual(status, TwoLevelCacheHitStatus.memory)
                expectation1.fulfill()
                cache.removeObject(forMemoryCacheKey: url)
                cache.findObject(forKey: url) { (image, status) in
                    XCTAssertNotNil(image)
                    XCTAssertEqual(status, TwoLevelCacheHitStatus.file)
                    expectation2.fulfill()
                }
            }
        }
        wait(for: [expectation0, expectation1, expectation2], timeout: 30)
    }
    
    func testInitialization() {
        let cache = try? TwoLevelCache<UIImage>("cache")
        XCTAssertNotNil(cache)
    }
    
    func testRemovingCaches() {
        let cache = generateImageCache()
        let expectation0 =
            self.expectation(description: "downloading an image")
        let url = TestsSampleImageUrl + "?v=\(Date().timeIntervalSince1970)"
        cache.findObject(forKey: url) { (image, status) in
            XCTAssertNotNil(image)
            XCTAssertEqual(status, TwoLevelCacheHitStatus.downloader)
            sleep(1)
            cache.removeObject(forMemoryCacheKey: url)
            XCTAssertNil(cache.object(forMemoryCacheKey: url))
            XCTAssertNotNil(cache.object(forFileCacheKey: url))
            cache.removeObject(forFileCacheKey: url)
            XCTAssertNil(cache.object(forMemoryCacheKey: url))
            XCTAssertNil(cache.object(forFileCacheKey: url))
            expectation0.fulfill()
        }
        wait(for: [expectation0], timeout: 30)
    }
    
    func testRemovingAllObjects() {
        let cache = generateImageCache()
        let image = UIImage(named: TestsSampleImagePath)!
        cache.setObject(image, forKey: TestsSampleImagePath)
        let memoryCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(memoryCached)
        let fileCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(fileCached)
        cache.removeAllObjects()
        let memoryNotCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNil(memoryNotCached)
        let fileNotCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNil(fileNotCached)
    }
    
    func testRemovingAllObjectsWithCallback() {
        let cache = generateImageCache()
        let image = UIImage(named: TestsSampleImagePath)!
        cache.setObject(image, forKey: TestsSampleImagePath)
        let memoryCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(memoryCached)
        let fileCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(fileCached)
        cache.removeAllObjects {
            let memoryNotCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
            XCTAssertNil(memoryNotCached)
            let fileNotCached = cache.object(forFileCacheKey: TestsSampleImagePath)
            XCTAssertNil(fileNotCached)
        }
    }
    
    func testRemovingObject() {
        let cache = generateImageCache()
        let image = UIImage(named: TestsSampleImagePath)!
        cache.setObject(image, forKey: TestsSampleImagePath)
        let memoryCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(memoryCached)
        let fileCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(fileCached)
        cache.removeObject(forKey: TestsSampleImagePath)
        let memoryNotCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNil(memoryNotCached)
        let fileNotCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNil(fileNotCached)
    }
    
    func testRemovingObjectForFileCache() {
        let cache = generateImageCache()
        let image = UIImage(named: TestsSampleImagePath)!
        cache.setObject(image, forKey: TestsSampleImagePath)
        let memoryCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(memoryCached)
        let fileCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(fileCached)
        cache.removeObject(forFileCacheKey: TestsSampleImagePath)
        let memoryStillCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(memoryStillCached)
        let fileNotCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNil(fileNotCached)
    }
    
    func testRemovingObjectForMemoryCache() {
        let cache = generateImageCache()
        let image = UIImage(named: TestsSampleImagePath)!
        cache.setObject(image, forKey: TestsSampleImagePath)
        let memoryCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(memoryCached)
        let fileCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(fileCached)
        cache.removeObject(forMemoryCacheKey: TestsSampleImagePath)
        let memoryNotCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNil(memoryNotCached)
        let fileStillCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(fileStillCached)
    }
    
    func testSettingData() {
        let cache = generateImageCache()
        let image = UIImage(named: TestsSampleImagePath)!
        cache.setData(UIImagePNGRepresentation(image)!, forKey: TestsSampleImagePath)
        let memoryCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(memoryCached)
        XCTAssertEqual(memoryCached!.size, image.size)
        let fileCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(fileCached)
        XCTAssertEqual(fileCached!.size, image.size)
    }
    
    func testSettingDataForFileCache() {
        let cache = generateImageCache()
        let image = UIImage(named: TestsSampleImagePath)!
        cache.setData(UIImagePNGRepresentation(image)!, forFileCacheKey: TestsSampleImagePath)
        let memoryCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNil(memoryCached)
        let fileCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(fileCached)
        XCTAssertEqual(fileCached!.size, image.size)
    }
    
    func testSettingDataForMemoryCache() {
        let cache = generateImageCache()
        let image = UIImage(named: TestsSampleImagePath)!
        cache.setData(UIImagePNGRepresentation(image)!, forMemoryCacheKey: TestsSampleImagePath)
        let memoryCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(memoryCached)
        XCTAssertEqual(memoryCached!.size, image.size)
        let fileCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNil(fileCached)
    }
    
    func testSettingObject() {
        let cache = generateImageCache()
        let image = UIImage(named: TestsSampleImagePath)!
        cache.setObject(image, forKey: TestsSampleImagePath)
        let memoryCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(memoryCached)
        XCTAssertEqual(memoryCached!.size, image.size)
        let fileCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(fileCached)
        XCTAssertEqual(fileCached!.size, image.size)
    }
    
    func testSettingObjectForFileCache() {
        let cache = generateImageCache()
        let image = UIImage(named: TestsSampleImagePath)!
        cache.setObject(image, forFileCacheKey: TestsSampleImagePath)
        let memoryCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNil(memoryCached)
        let fileCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(fileCached)
        XCTAssertEqual(fileCached!.size, image.size)
    }
    
    func testSettingObjectForMemoryCache() {
        let cache = generateImageCache()
        let image = UIImage(named: TestsSampleImagePath)!
        cache.setObject(image, forMemoryCacheKey: TestsSampleImagePath)
        let memoryCached = cache.object(forMemoryCacheKey: TestsSampleImagePath)
        XCTAssertNotNil(memoryCached)
        XCTAssertEqual(memoryCached!.size, image.size)
        let fileCached = cache.object(forFileCacheKey: TestsSampleImagePath)
        XCTAssertNil(fileCached)
    }
    
    private func generateImageCache() -> TwoLevelCache<UIImage> {
        let cache = try! TwoLevelCache<UIImage>("test-cache")
        cache.downloader = { (key, callback) in
            let url = URL(string: key)!
            URLSession.shared.dataTask(with: url) { data, response, error in
                callback(data)
                }.resume()
        }
        cache.deserializer = { (data) in
            return UIImage(data: data)
        }
        cache.serializer = { (object) in
            return UIImagePNGRepresentation(object)
        }
        cache.removeAllObjects()
        return cache
    }
}

extension Tests {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
