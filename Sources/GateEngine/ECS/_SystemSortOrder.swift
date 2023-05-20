/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

enum _SystemSortOrder: Int {
    case tileMapSystem      = 0_100
    case spriteSystem       = 0_200
    
    case physics2DSystem    = 2_100
    case collision2DSystem  = 2_200
    
    case physics3DSystem    = 3_100
    case colision3DSystem   = 3_200
    
    case rigSystem          = 4_100
}
