//
//  ViewController.swift
//  RxSwiftSample
//
//  Created by hyunndy on 2020/08/27.
//  Copyright © 2020 hyunndy. All rights reserved.
//

/*
 RxSwift
 
 RxSwift는 Observable 객체를 이용해서 값을 배출할 수 있고, 그 배출값을 구독(Subscribe)하고 반응한다.
 
 Observabable은 3가지 행동 규칙(Stream)이 존재한다.
 1) next
    - Observable은 next 스트림을 통해서 연속된 값들을 배출하고, 옵저버는 next 스트림을 관찰(Observe), 구독(Subscribe)해서 원하는 행동을 하게된다.
 2) error
    - 값을 배출하다가 에러가 생기면 error을 배출한 다음 해당 Observable은 스트림을 멈추게된다.
 3) complete
    - Observable의 next가 더이상 배출하지 않으면. 즉, 모든 값을 다 배출하면 complete 된다.
 
 Observable의 create -> on[Next, Error, Complete] 정의 -> Observable 객체를 Subscribe 하면서 Stream을 관찰하고 구독
 
 Disposable
 : 처분할 수 있는, 사용 후 버릴 수 있는
 : Completed 된 후에 Disposable 버려진 것.
 -> Observable을 subscribe 하면 Disposable 타입을 반환한다.
 
 disposeBag
 
 모든 disposable 객체에 disposed를 해주면 해당 파라미터인 disposeBag에 등록 되고,
 disposeBag 객체가 헤제되면서 등록된 모든 disposable이 다같이 dispose 된다.
 
 'disposeBag이 해제 되면 모든 disposable이 dispose 되는 원리를
 개발도중 사용할수 있습니다.' 라는 원리를 개발도중 사용할 수 있다.
 -> subscribe 중이던 disposable을 초개화 하고 싶으면 disposeBag 프로퍼티에 새로운 DisposeBag을 할당한다.
 */

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    @IBOutlet weak var lbCustom: UILabel!
    
    deinit {
        print("deinit CustomViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // interval() : n초 마다 정수 타입의 stream이 emit 된다.
        // take() : parameter로 들어가는 만큼의 스트림을 허용한다.
        let disposable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .take(10)
            .subscribe(onNext: { value in
                print(value)
            }, onError: { error in
                print(error)
            }, onCompleted: {
                print("OnCompleted")
            }, onDisposed: {
                print("OnDisposed")
            })
            .disposed(by: self.disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            // resource를 처분해!
//            disposable.dispose()
            
            UIApplication.shared.keyWindow?.rootViewController = nil
        }
//
//        checkArrayObservable(items: [4,3,5,2])
//            .subscribe { event in
//                switch event {
//                case .next(let value):
//                    print(value)
//                case .error(let error):
//                    print(error)
//                case .completed:
//                    print("completed")
//                }
//        }
//        .disposed(by: self.disposeBag)
    }
    
    // 정수 제네릭 타입의 Observable 객체를 반환
    func checkArrayObservable(items: [Int]) -> Observable<Int> {
        return Observable<Int>.create { observer -> Disposable in
            
            for item in items {
                
                // Error 발생시키기!
                if item == 0 {
                    observer.onError(NSError(domain: "ERROR: value is zero", code: 0, userInfo: nil))
                    break
                }
                
                // Next 발생시키기!
                observer.onNext(item)
                
                sleep(1)
            }
            
            // Next가 더이상 발행되지 않으면 Complete.
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
}

