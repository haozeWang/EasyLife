//
//  ShowSplashScreen.swift
//  EasyLife
//
//  Created by 王昊泽 on 17/3/14.
//  Copyright © 2017年 Haoze Wang. All rights reserved.
//

import UIKit

class ShowSplashScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        perform(#selector(self.showsplashscreen), with: nil, afterDelay: 2)
        // Do any additional setup after loading the view.
    }
    
    func showsplashscreen(){
        performSegue(withIdentifier: "showsplashscrenn", sender: UIView())
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
