
/**
 * Created with IntelliJ IDEA.
 * User: Administrator
 * Date: 14-12-24
 * Time: 下午9:51
 * To change this template use File | Settings | File Templates.
 */
target(copyBui:"copy bui to web"){
      def buidir="${basedir}/web-app/bui"
      File buidirFile=new File(buidir);
    if(!buidirFile.exists()){
        ant.mkdir(dir: buidir)
        def buiResource="${grailsHome}/src/web/bui"
        ant.copy(todir: "${basedir}/web-app/bui/", overwrite: true){
            fileset(dir: buiResource) {
                include(name: "**/**")
            }
        }
        ant.println("copy bui finished")
    }else{
        ant.input(message:"bui is exists,overwrite?. Please enter(yes or no):",
                addProperty:"overwrite",defaultValue:"yew")
        if(overwrite=="yes"){
            def buiResource="${grailsHome}/src/web/bui"
            ant.copy(todir: "${basedir}/web-app/bui/", overwrite: true){
                fileset(dir: buiResource) {
                    include(name: "**/**")
                }
            }
            ant.println("bui overwrite finished")
        }else{
            ant.println("skiped copy bui")
        }
    }
}