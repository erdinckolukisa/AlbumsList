//
//  AppsFactoryTestTaskTests.swift
//  AppsFactoryTestTaskTests

import XCTest
import CoreData
@testable import AppsFactoryTestTask

class AppsFactoryTestTaskTests: XCTestCase {
    var networking: Networkable!
    var peristable: Persistable!
    var albumDetailModel: AlbumDetailModel!
    var albumEntity: AlbumEntity!
    var context: NSManagedObjectContext!
    override func setUp() {
        networking = StubApi()
        // - CoreDataStorage(isForTesting: true) isForTesting parameter is used to work from memory in order to get same results for every seperate tests and preventing existing local storage
        context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainerForTesting.viewContext
        peristable = CoreDataStorage(isForTesting: true)
    }
    
    override func tearDown() {
        networking = nil
        peristable = nil
        albumDetailModel = nil
        context = nil
    }
    
    func testTrackViewModel() {
        let trackViewModel = TrackViewModel(trackName: "TrackName", artistName: "TrackArtis", trackDuration: "120")
        XCTAssertNotNil(trackViewModel)
        XCTAssertEqual(trackViewModel.trackName, "TrackName", "TrackName was expected")
        XCTAssertEqual(trackViewModel.artistName, "TrackArtis", "TrackArtis was expected")
        XCTAssertEqual(trackViewModel.trackDuration, "2:00", "2:00 was expected")
        XCTAssertNotEqual(trackViewModel.trackDuration, "2:0", "2:00 was expected")
    }
    
    func testSearchArtistsApi() {
        let searchArtistsApiExpectation = expectation(description: "Search artists from stub service")
        networking.searchArtists(searchText: "cher") { result, error in
            XCTAssertNil(error, "Error must be nil")
            XCTAssertNotNil(result)
            XCTAssert(result?.objects?.artist?.count ?? 0 > 0, "Artist count must be more than 0")
            XCTAssertEqual(result?.objects?.artist?.first?.name, "Cher", "Based on stub file first artist must be Cher. Model or stub file should be checked")
            XCTAssertEqual(result?.objects?.artist?.first?.image?.first?.url, "https://lastfm.freetls.fastly.net/i/u/34s/2a96cbd8b46e442fc41c2b86b821562f.png", "Based on stub file url is wrong. Model or stub file should be checked")
            XCTAssertEqual(result?.objects?.artist?.first?.mbid, "bfcc6d75-a6a5-4bc6-8282-47aec8531818", "Based on stub file mbid is wrong. Model or stub file should be checked")
            searchArtistsApiExpectation.fulfill()
        }
        wait(for: [searchArtistsApiExpectation], timeout: 2)
    }
    
    func testGetAlbumsApi() {
        let getAlbumsApiExpectation = expectation(description: "Search artists from stub service")
        networking.getTopAlbums(artistId: "bfcc6d75-a6a5-4bc6-8282-47aec8531818") { topAlbums, error in
            XCTAssertNil(error, "Error must be nil")
            XCTAssertNotNil(topAlbums)
            XCTAssertEqual(topAlbums?.album?.count, 50, "Based on stub file 50 result is expected. Model or stub file should be checked")
            XCTAssertEqual(topAlbums?.album?.first?.name, "Believe", "Based on stub file Believe is expected. Model or stub file should be checked")
            XCTAssertEqual(topAlbums?.album?.first?.mbid, "63b3a8ca-26f2-4e2b-b867-647a6ec2bebd", "Based on stub file 63b3a8ca-26f2-4e2b-b867-647a6ec2bebd is expected. Model or stub file should be checked")
            XCTAssertEqual(topAlbums?.album?.first?.image?.last?.url, "https://lastfm.freetls.fastly.net/i/u/300x300/3b54885952161aaea4ce2965b2db1638.png", "Based on stub file url is wrong. Model or stub file should be checked")
            getAlbumsApiExpectation.fulfill()
        }
        wait(for: [getAlbumsApiExpectation], timeout: 2)
    }
    
    func testGetAlbumDetail() {
        let getAlbumDetailExpectation = expectation(description: "Album details from stub service")
        networking.getAlbumDetail(albumId: "63b3a8ca-26f2-4e2b-b867-647a6ec2bebd") { albumDetailModel, error in
            XCTAssertNil(error, "Error must be nil")
            XCTAssertNotNil(albumDetailModel)
            XCTAssertEqual(albumDetailModel?.albumName, "Believe", "Based on stub file Believe is expected. Model or stub file should be checked")
            XCTAssertEqual(albumDetailModel?.mbid, "63b3a8ca-26f2-4e2b-b867-647a6ec2bebd", "Based on stub file 63b3a8ca-26f2-4e2b-b867-647a6ec2bebd is expected. Model or stub file should be checked")
            XCTAssertEqual(albumDetailModel?.albumTracks?.first?.name, "Believe", "Based on stub file Believe is expected. Model or stub file should be checked")
            XCTAssertEqual(albumDetailModel?.albumTracks?.last?.name, "We All Sleep Alone", "Based on stub file value is wrong. Model or stub file should be checked")
            XCTAssertEqual(albumDetailModel?.albumTracks?.count, 10, "Based on stub file 50 result is expected. Model or stub file should be checked")
            getAlbumDetailExpectation.fulfill()
        }
        wait(for: [getAlbumDetailExpectation], timeout: 2)
    }
    
    func testCoreDataStorage() {
        let coreDataStorageExpectation = expectation(description: "CoreDataStorage expectation")
        let albumEntity = AlbumEntity(context: context)
        albumEntity.mbid = "12345"
        albumEntity.name = "TestAlbumName"
        albumEntity.artistName = "TestArtistName"
        albumEntity.albumDescription = "TestAlbumDescription"
        var trackEntity = TracksEntity(context: context)
        trackEntity.album = albumEntity
        trackEntity.trackName = "TestTrackName"
        trackEntity.duration = "100"
        trackEntity.artistName = "TestTrackArtistName"
        
        albumEntity.addToTracks(trackEntity)
        
        var albumDetailModel = AlbumDetailModel(albumEntity: albumEntity)
        peristable.saveAlbum(album: albumDetailModel) { error in
            XCTAssertNil(error, "Error must be nil")
        }
        
        peristable.getAllAlbums { storedAlbums, error in
            XCTAssertNil(error, "Error must be nil")
            XCTAssertNotNil(storedAlbums)
            XCTAssertEqual(storedAlbums?.first?.albumName, "TestAlbumName", "TestAlbumName was expected")
            XCTAssertEqual(storedAlbums?.first?.mbid, "12345", "12345 was expected")
        }
        
        peristable.getAlbumDetail(albumId: "12345") { albumDetail, error in
            XCTAssertNil(error, "Error must be nil")
            XCTAssertNotNil(albumDetail)
            XCTAssertEqual(albumDetail?.albumName, "TestAlbumName", "TestAlbumName was expected")
            XCTAssertEqual(albumDetail?.mbid, "12345", "12345 was expected")
            XCTAssertEqual(albumDetail?.albumTracks?.count, 1, "1 was expected")
            XCTAssertEqual(albumDetail?.albumTracks?.first?.name, "TestTrackName", "TestTrackName was expected")
            XCTAssertEqual(albumDetail?.albumTracks?.first?.artistName, "TestTrackArtistName", "TestArtistName was expected")
            XCTAssertEqual(albumDetail?.albumTracks?.first?.duration, "100", "100 was expected")
        }
        
        peristable.deleteAlbum(mbid: "12345") {
            
        }
        
        peristable.getAllAlbums { storedAlbums, error in
            XCTAssertNil(error, "Error must be nil")
            XCTAssertNotNil(storedAlbums)
            XCTAssertEqual(storedAlbums?.count, 0, "0 was expected")
            XCTAssertNotEqual(storedAlbums?.first?.mbid, "12345", "12345 was expected")
            coreDataStorageExpectation.fulfill()
        }
        
        wait(for: [coreDataStorageExpectation], timeout: 3)
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
