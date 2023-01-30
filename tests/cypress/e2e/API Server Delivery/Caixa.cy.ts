describe('Rotas caixa', () => {
    let id:number;

    it('Criar caixa - 01', () => {
        cy.request({
            method: 'POST',
            url: '/caixas'
        }).then((Response) => {
            let hoje = new Date(Date.now());

            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Caixa aberto com sucesso!');
            expect(Response.body[1].total).to.equal(0.00);
            expect(new Date(Response.body[1].dataAbertura).getDate()+1).to.equal(hoje.getDate());
            id = Response.body[1].id;
        });
    });
    
    it('Criar caixa com caixa já aberto', () => {        
        cy.request({
            method: 'POST',
            url: '/caixas',
            failOnStatusCode: false
        }).then((Response) => {
            expect(Response.status).to.equal(400);
            expect(Response.body.message).to.equal('Caixa já está aberto!');
        });
    });

    it('Buscar caixas', () => {
        cy.request('/caixas')
            .then((Response) => {
                expect(Response.status).to.equal(200);
                expect(Response.body.length).to.gte(1);
            });
    });

    it('Buscar caixas por data', () => {
        const padTo2Digits = (num: number)=> {
                return num.toString().padStart(2, '0');
        }
        
        const date = new Date();

        let dt = [
            date.getFullYear(),
            padTo2Digits(date.getMonth() + 1),
            padTo2Digits(date.getDate()),
        ].join('-');

        cy.request('/caixas?dataCaixa=30-01-2023')
            .then((Response) => {
                expect(Response.status).to.equal(200);
                expect(Response.body.length).to.gte(1);
                expect(Response.body[0].dataAbertura).to.equal(dt);
            });
    });

    it('Buscar caixas entre data', () => {
        const padTo2Digits = (num: number)=> {
                return num.toString().padStart(2, '0');
        }
        
        const date = new Date();

        let dt = [
            date.getFullYear(),
            padTo2Digits(date.getMonth() + 1),
            padTo2Digits(date.getDate()),
        ].join('-');

        cy.request('/caixas?dataInicial=27-01-2023&dataFinal=30-01-2023')
            .then((Response) => {
                expect(Response.status).to.equal(200);
                expect(Response.body.length).to.gte(1);
                expect(Response.body[0].dataAbertura).to.contain(dt);
            });
    });

    it('Buscar caixa por ID', () => {
        cy.request(`/caixas/${id}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id);
        });
    });

    it('Fechar caixa', () => {
        cy.request({
            method: 'PUT',
            url: `/caixas/fechar/${id}`
        }).then(Response => {
            expect(Response.status).to.equal(200);
            expect(Response.body[1].id).to.equal(id);
            expect(Response.body[1].aberto).to.equal(false);
        });
    });

});