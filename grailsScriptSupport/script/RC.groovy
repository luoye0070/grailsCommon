
/**
 * Created with IntelliJ IDEA.
 * User: Administrator
 * Date: 14-12-24
 * Time: 下午10:31
 * To change this template use File | Settings | File Templates.
 */
includeTargets << grailsScript("_ResourceCopy")
target(main:"Resource Copy"){
    copyBui()
}
setDefaultTarget(main)